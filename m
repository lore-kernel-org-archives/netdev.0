From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [PATCH] igb: Fix a memory leak in igb_probe
Date: Tue, 11 Aug 2015 02:13:48 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B81AE35CA@ORSMSX101.amr.corp.intel.com>
References: <1438783516-13283-1-git-send-email-baijiaju1990@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Jia-Ju Bai <baijiaju1990@163.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438783516-13283-1-git-send-email-baijiaju1990@163.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Jia-Ju Bai
> Sent: Wednesday, August 05, 2015 7:05 AM
> To: Kirsher, Jeffrey T; Brandeburg, Jesse
> Cc: intel-wired-lan@lists.osuosl.org; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; Jia-Ju Bai
> Subject: [PATCH] igb: Fix a memory leak in igb_probe
> 
> In error handling code of igb_probe, the memory adapter->shadow_vfta
> allocated by kcalloc in igb_sw_init is not freed. So when register_netdev
> or igb_init_i2c is failed, a memory leak will occur.
> This patch adds kfree to fix it.
> 
> Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
> ---
>  drivers/net/ethernet/intel/igb/igb_main.c |    1 +
>  1 file changed, 1 insertion(+)

Tested-by: Aaron Brown <aaron.f.brown@intel.com>
