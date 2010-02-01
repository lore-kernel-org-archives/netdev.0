From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [net-next-2.6 v2] can: add support for CAN interface cards	based
	on the PLX90xx PCI bridge
Date: Mon, 01 Feb 2010 21:31:06 +0100
Message-ID: <4B673A0A.5080504@grandegger.com>
References: <1265053364-24099-1-git-send-email-chebl@star.inp.nsk.su>
	<20100201195611.GB32624@ovro.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Ira W. Snyder" <iws-lulEs6mt1IksTUYHLfqkUA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20100201195611.GB32624-lulEs6mt1IksTUYHLfqkUA@public.gmane.org>
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
> On Tue, Feb 02, 2010 at 01:42:44AM +0600, Pavel B. Cheblakov wrote:
>> From: Pavel Cheblakov <P.B.Cheblakov-tHBF8D5G73F4OK5fxMSSsQ@public.gmane.org>
>>
>> This driver is for CAN interface cards based on the PLX90xx PCI bridge.
>> Driver supports now:
>>  - Adlink PCI-7841/cPCI-7841 card (http://www.adlinktech.com/)
>>  - Adlink PCI-7841/cPCI-7841 SE card
>>  - Marathon CAN-bus-PCI card (http://www.marathon.ru/)
>>  - TEWS TECHNOLOGIES TPMC810 card (http://www.tews.com/)
>>
>> Changes since v1:
>>  - Added some defines for static inline int plx_pci_check_sja1000(...)
>>  - static struct pci_device_id plx_pci_tbl[] replaced by
>>    static DEFINE_PCI_DEVICE_TABLE(plx_pci_tbl)
>>  - Typo fixed
>>
> 
> Hello,
> 
> Any ideas if this driver could support the Janz PCI CAN cards as well? I
> don't have any documentation for the cards, and I'd love to get away
> from their closed-source drivers.

Is it a passive or and intelligent CAN PCI card? What is the name of the
card? A intelligent card will run its own firmware and you do not have
direct access to the SJA1000. Pavel plx_pci driver is quite generic and
it should not be a big deal to support a PLX90xx based passive card.

Wolfgang.

Wolfgang.
