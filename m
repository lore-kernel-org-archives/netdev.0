From: Ethan Zhao <ethan.kernel@gmail.com>
Subject: Re: [PATCH] ixgbe: remove useless bd_number from
	adapter struct
Date: Tue, 29 Jul 2014 10:59:49 +0800
Message-ID: <CABawtvMWmi4c-9C_EWZpOusjLHYNv0fwDW4uHoQZ9G0sS9NH8w@mail.gmail.com>
References: <1406533278-27979-1-git-send-email-ethan.zhao@oracle.com>
	<309B89C4C689E141A5FF6A0C5FB2118B73366373@ORSMSX104.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Ethan Zhao <ethan.zhao@oracle.com>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>, "Brandeburg,
	Jesse" <jesse.brandeburg@intel.com>,
	Linux NICS <Linux-nics@isotope.jf.intel.com>, "Ronciak,
	John" <john.ronciak@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Brown, Aaron F" <aaron.f.brown@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <309B89C4C689E141A5FF6A0C5FB2118B73366373@ORSMSX104.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Thanks Brown, Aaron F

On Tue, Jul 29, 2014 at 10:51 AM, Brown, Aaron F
<aaron.f.brown@intel.com> wrote:
>> From: linux-kernel-owner@vger.kernel.org [mailto:linux-kernel-
>> owner@vger.kernel.org] On Behalf Of Ethan Zhao
>> Sent: Monday, July 28, 2014 12:41 AM
>> To: Kirsher, Jeffrey T; Brandeburg, Jesse; Allan, Bruce W; Wyborny,
>> Carolyn; Skidmore, Donald C; Rose, Gregory V; Duyck, Alexander H; Ronciak,
>> John; Williams, Mitch A
>> Cc: Linux NICS; e1000-devel@lists.sourceforge.net; netdev@vger.kernel.org;
>> linux-kernel@vger.kernel.org; ethan.kernel@gmail.com; Ethan Zhao
>> Subject: [PATCH] ixgbe: remove useless bd_number from adapter struct
>>
>> Because bd_number is not useful anymore, so remove it from adapter struct,
>> or
>> if keep it, we have to fix the boards driven counter bug in ixgbe_remove()
>> and
>> ixgbe_probe() only for trival debug purpose -- other output is enough.
>
> Thanks Ethan, I (briefly covering for Jeff Kirsher) have added this patch and your other one ofr ixgbevf to Jeff's internal tree.

------------------------------------------------------------------------------
Infragistics Professional
Build stunning WinForms apps today!
Reboot your WinForms applications with our WinForms controls. 
Build a bridge from your legacy apps to the future.
http://pubads.g.doubleclick.net/gampad/clk?id=153845071&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
