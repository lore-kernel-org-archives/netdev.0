From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: Re: [PATCH] ixgbe: remove useless bd_number from
	adapter struct
Date: Tue, 29 Jul 2014 02:51:25 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B73366373@ORSMSX104.amr.corp.intel.com>
References: <1406533278-27979-1-git-send-email-ethan.zhao@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"ethan.kernel@gmail.com" <ethan.kernel@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Linux NICS <Linux-nics@isotope.jf.intel.com>
To: Ethan Zhao <ethan.zhao@oracle.com>, "Kirsher, Jeffrey T"
	<jeffrey.t.kirsher@intel.com>, "Brandeburg, Jesse"
	<jesse.brandeburg@intel.com>, "Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>, "Skidmore, Donald C"
	<donald.c.skidmore@intel.com>, "Rose,
	Gregory V" <gregory.v.rose@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>, "Ronciak, John"
	<john.ronciak@intel.com>, "Williams, Mitch A" <mitch.a.williams@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1406533278-27979-1-git-send-email-ethan.zhao@oracle.com>
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

> From: linux-kernel-owner@vger.kernel.org [mailto:linux-kernel-
> owner@vger.kernel.org] On Behalf Of Ethan Zhao
> Sent: Monday, July 28, 2014 12:41 AM
> To: Kirsher, Jeffrey T; Brandeburg, Jesse; Allan, Bruce W; Wyborny,
> Carolyn; Skidmore, Donald C; Rose, Gregory V; Duyck, Alexander H; Ronciak,
> John; Williams, Mitch A
> Cc: Linux NICS; e1000-devel@lists.sourceforge.net; netdev@vger.kernel.org;
> linux-kernel@vger.kernel.org; ethan.kernel@gmail.com; Ethan Zhao
> Subject: [PATCH] ixgbe: remove useless bd_number from adapter struct
> 
> Because bd_number is not useful anymore, so remove it from adapter struct,
> or
> if keep it, we have to fix the boards driven counter bug in ixgbe_remove()
> and
> ixgbe_probe() only for trival debug purpose -- other output is enough.

Thanks Ethan, I (briefly covering for Jeff Kirsher) have added this patch and your other one ofr ixgbevf to Jeff's internal tree.

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
