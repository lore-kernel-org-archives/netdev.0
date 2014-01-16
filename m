From: Ethan Zhao <ethan.kernel@gmail.com>
Subject: Re: [PATCH 1/2 v3] ixgbe: define
 IXGBE_MAX_VFS_DRV_LIMIT macro and cleanup const 63
Date: Thu, 16 Jan 2014 09:58:37 +0800
Message-ID: <CABawtvNSpDU+pjdJOpCB8kyQqA7B9N4g0S_yPgQaZnB3h0+nFg@mail.gmail.com>
References: <1389795148-341-1-git-send-email-ethan.kernel@gmail.com>
	<309B89C4C689E141A5FF6A0C5FB2118B7312DA20@ORSMSX101.amr.corp.intel.com>
	<CABawtvNEDjTJAjJ9TeEvZd7+2kD=H6zA23T-aQo3uVm5SUEhCQ@mail.gmail.com>
	<309B89C4C689E141A5FF6A0C5FB2118B7312DE7D@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Allan,
	Bruce W" <bruce.w.allan@intel.com>, "Brandeburg,
	Jesse" <jesse.brandeburg@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "Brown, Aaron F" <aaron.f.brown@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <309B89C4C689E141A5FF6A0C5FB2118B7312DE7D@ORSMSX101.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Aaron,

Is this your net-next repo ? if so, I rebuild the patch with this repo
right now .
git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next.git

Thanks,
Ethan

On Thu, Jan 16, 2014 at 9:54 AM, Brown, Aaron F <aaron.f.brown@intel.com> wrote:
> On Thu, 2014-01-16 at 09:27 +0800, Ethan Zhao wrote:
>> On Thu, Jan 16, 2014 at 6:00 AM, Brown, Aaron F <aaron.f.brown@intel.com> wrote:
>> > On Wed, 2014-01-15 at 22:12 +0800, Ethan Zhao wrote:
>> >> Because ixgbe driver limit the max number of VF functions could be enabled
>> >> to 63, so define one macro IXGBE_MAX_VFS_DRV_LIMIT and cleanup the const 63
>> >> in code.
>> >>
>> >> v2: fix a typo.
>> >> v3: fix a encoding issue.
>> >>
>> >> Signed-off-by: Ethan Zhao <ethan.kernel@gmail.com>
>> >> ---
>> >>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  | 4 ++--
>> >>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 5 +++--
>> >>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h | 5 +++++
>> >>  3 files changed, 10 insertions(+), 4 deletions(-)
>> >>
>> >> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>> >> index 0ade0cd..47e9b44 100644
>> >> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>> >> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>> >> @@ -4818,7 +4818,7 @@ static int ixgbe_sw_init(struct ixgbe_adapter *adapter)
>> >>  #ifdef CONFIG_PCI_IOV
>> >>       /* assign number of SR-IOV VFs */
>> >>       if (hw->mac.type != ixgbe_mac_82598EB)
>> >> -             adapter->num_vfs = (max_vfs > 63) ? 0 : max_vfs;
>> >
>> >
>> > Unfortunately the if statement got changed considerably with a recent
>> > commit:
>> >
>> > commit 170e85430bcbe4d18e81b5a70bb163c741381092
>> > ixgbe: add warning when max_vfs is out of range.
>> >
>> > And the pattern no longer exists to make a match.  In other words, this
>> > patch no longer applies to net-next and I have to ask you for yet
>> > another spin if you still want to squash the magic number.
>>
>> It's not a good news. Our distro is waiting for this patch showing up in stable.
>> OK, info me if there is a windows for me to revise the patch.
>
> I don't think any particular window of time is better than another. I
> don't see this change as needing very thorough testing so if you send in
> (yet) another version I'll try to get it through our internal process as
> rapidly as I can.
>
>>
>> Thanks,
>> Ethan
>>
>> >
>> > Thanks,
>> > Aaron
>

------------------------------------------------------------------------------
CenturyLink Cloud: The Leader in Enterprise Cloud Services.
Learn Why More Businesses Are Choosing CenturyLink Cloud For
Critical Workloads, Development Environments & Everything In Between.
Get a Quote or Start a Free Trial Today. 
http://pubads.g.doubleclick.net/gampad/clk?id=119420431&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
