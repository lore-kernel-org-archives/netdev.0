From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [net-next-2.6 v2] can: add support for CAN interface cards	based
	on the PLX90xx PCI bridge
Date: Tue, 02 Feb 2010 09:02:58 +0100
Message-ID: <4B67DC32.3080206@grandegger.com>
References: <1265053364-24099-1-git-send-email-chebl@star.inp.nsk.su>	<20100201195611.GB32624@ovro.caltech.edu>	<4B673A0A.5080504@grandegger.com>
	<20100201210507.GD32624@ovro.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Ira W. Snyder" <iws-lulEs6mt1IksTUYHLfqkUA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20100201210507.GD32624-lulEs6mt1IksTUYHLfqkUA@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Ira W. Snyder wrote:
> On Mon, Feb 01, 2010 at 09:31:06PM +0100, Wolfgang Grandegger wrote:
>> Ira W. Snyder wrote:
>>> On Tue, Feb 02, 2010 at 01:42:44AM +0600, Pavel B. Cheblakov wrote:
>>>> From: Pavel Cheblakov <P.B.Cheblakov-tHBF8D5G73F4OK5fxMSSsQ@public.gmane.org>
>>>>
>>>> This driver is for CAN interface cards based on the PLX90xx PCI bridge.
>>>> Driver supports now:
>>>>  - Adlink PCI-7841/cPCI-7841 card (http://www.adlinktech.com/)
>>>>  - Adlink PCI-7841/cPCI-7841 SE card
>>>>  - Marathon CAN-bus-PCI card (http://www.marathon.ru/)
>>>>  - TEWS TECHNOLOGIES TPMC810 card (http://www.tews.com/)
>>>>
>>>> Changes since v1:
>>>>  - Added some defines for static inline int plx_pci_check_sja1000(...)
>>>>  - static struct pci_device_id plx_pci_tbl[] replaced by
>>>>    static DEFINE_PCI_DEVICE_TABLE(plx_pci_tbl)
>>>>  - Typo fixed
>>>>
>>> Hello,
>>>
>>> Any ideas if this driver could support the Janz PCI CAN cards as well? I
>>> don't have any documentation for the cards, and I'd love to get away
>>> from their closed-source drivers.
>> Is it a passive or and intelligent CAN PCI card? What is the name of the
>> card? A intelligent card will run its own firmware and you do not have
>> direct access to the SJA1000. Pavel plx_pci driver is quite generic and
>> it should not be a big deal to support a PLX90xx based passive card.
>>
> 
> It is an intelligent CAN PCI card. I'm pretty sure they're the card
> described here: http://www.janz.de/as/en/can-cp6/k2.html
> 
> Since this driver is for passive cards, it clearly won't work. Are there
> any examples of drivers written for intelligent CAN cards? Until I found
> the website above, I'd never seen any data sheets for this card. They
> look like they may have enough information to write a driver to
> interface with the new Linux CAN layer.

The esd_pci331 driver from the SVN repository is for an intelligent
card, if I remember correctly. But using an intelligent card just for
the raw CAN protocol seems kind of overkill to me.

> We should probably start a new thread about this, it is getting
> off-topic for Pavel's CAN driver. Is the socketcan mailing list ok for
> this kind of discussion?

Of course, if it's about Socket-CAN.

Wolfgang.

> Thanks,
> Ira
> _______________________________________________
> Socketcan-core mailing list
> Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
> https://lists.berlios.de/mailman/listinfo/socketcan-core
> 
> 
