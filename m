From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH] igb: constify e1000_phy_operations
	structure
Date: Tue, 12 Jan 2016 03:44:08 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B81E4D3B1@ORSMSX101.amr.corp.intel.com>
References: <1451803496-16693-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Julia Lawall <Julia.Lawall@lip6.fr>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1451803496-16693-1-git-send-email-Julia.Lawall@lip6.fr>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: Intel-wired-lan [intel-wired-lan-bounces@lists.osuosl.org] on behalf of Julia Lawall [Julia.Lawall@lip6.fr]
> Sent: Saturday, January 02, 2016 10:44 PM
> To: Kirsher, Jeffrey T
> Cc: kernel-janitors@vger.kernel.org; linux-kernel@vger.kernel.org; intel-wired-lan@lists.osuosl.org; netdev@vger.kernel.org
> Subject: [Intel-wired-lan] [PATCH] igb: constify e1000_phy_operations   structure
> 
> This e1000_phy_operations structure is never modified, so declare it as
> const.  Other structures of this type are already const.
> 
> Done with the help of Coccinelle.
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> ---
>  drivers/net/ethernet/intel/igb/e1000_82575.c |    2 +-
>  drivers/net/ethernet/intel/igb/e1000_hw.h    |    2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)

Tested-by: Aaron Brown <aaron.f.brown@intel.com>
