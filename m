From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: Validation of DMA params breaks e100 driver
	(2.6.28-rc2)
Date: Fri, 14 Nov 2008 14:30:41 -0800
Message-ID: <F169D4F5E1F1974DBFAFABF47F60C10A0EB53E2A@orsmsx507.amr.corp.intel.com>
References: <4909E08F.9040306@users.sourceforge.net>
	<20081031210131.GA18015@flint.arm.linux.org.uk>
	<Pine.WNT.4.63.0811131718390.984@jbrandeb-desk.amr.corp.intel.com>
	<491DE18D.2070302@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	"linux-arm-kernel@lists.arm.linux.org.uk"
	<linux-arm-kernel@lists.arm.linux.org.uk>
To: =?iso-8859-1?Q?Anders_Grafstr=F6m?= <grfstrm@users.sourceforge.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <491DE18D.2070302@users.sourceforge.net>
Content-Language: en-US
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Anders Grafstr=F6m wrote:
> Brandeburg, Jesse wrote:
>> On Fri, 31 Oct 2008, Russell King - ARM Linux wrote:
>>
>>> On Thu, Oct 30, 2008 at 05:27:59PM +0100, Anders Grafstr=F6m wrote:
>>>> The e100 driver triggers BUG_ON(buf->direction !=3D dir)
>>>> by doing pci_map_single(..., PCI_DMA_BIDIRECTIONAL)
>>>> and pci_dma_sync_single_for_device(..., PCI_DMA_TODEVICE).
>>>>
>>>> I'm guessing it's allowed to do that and that something like
>>>> the patch below is called for?
>>> No, it is not allowed to do that - that's why it's called "BUG_ON".
>>> Changing the DMA direction, especially with dmabounce will result
>>> in unexpected behaviour.
>>
>> okay, how about this patch...  only compile tested as I couldn't get
>> net-next-2.6 to boot on my test machine.  I'll get some testing done
>> on this, but in the meantime....
>>
>> e100: fix dma error in direction for mapping
>>
>> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
>
> I failed to save this patch (flowed format?) but I applied it manually
> to 2.6.28-rc4 and tried it. Appears to work.

Strange... sorry for the thrash on the patch, and thanks for testing!


-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great priz=
es
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=3D100&url=3D/
