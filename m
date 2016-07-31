From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/4] drivers: net: cpsw: fix driver loading/unloading
Date: Sat, 30 Jul 2016 21:00:49 -0700 (PDT)
Message-ID: <20160730.210049.865458752683551165.davem@davemloft.net>
References: <20160728175037.22053-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mugunthanvnm@ti.com, nsekhar@ti.com,
	linux-kernel@vger.kernel.org, linux-omap@vger.kernel.org
To: grygorii.strashko@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160728175037.22053-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Grygorii Strashko <grygorii.strashko@ti.com>
Date: Thu, 28 Jul 2016 20:50:33 +0300

> This series fixes set of isssues observed when CPSW driver module is unloaded/loaded:
> 1) rmmod: deadlock in cpdma_ctlr_destroy
> 2) rmmod: L3 back-trace and crash if all net interfaces are down, because CPSW
> can be powerred down by PM runtime in this case.
> 3) insmod: mdio device is not recreated on next insmod
>  - need to use of_platform_depopulate() in cpsw_remove().
> 4) rmmod: system crash on omap_device removal
> 
> Tested on: am437x-idk, am57xx-beagle-x15
> 
> Changes in v2:
> - build warning fixed
> - added fix for correct omap_device removal
> 
> Link on v1:
>  https://lkml.org/lkml/2016/7/22/240

Series applied, thanks.
