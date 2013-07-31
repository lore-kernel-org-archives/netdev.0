From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/1] drivers: net: cpsw: Add support for new
 CPSW IP version
Date: Wed, 31 Jul 2013 16:55:30 -0700 (PDT)
Message-ID: <20130731.165530.1374328962435203697.davem@davemloft.net>
References: <1375272746-24446-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-omap@vger.kernel.org, balbi@ti.com
To: mugunthanvnm@ti.com
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1375272746-24446-1-git-send-email-mugunthanvnm@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mugunthan V N <mugunthanvnm@ti.com>
Date: Wed, 31 Jul 2013 17:42:26 +0530

> The new IP version has a minor changes and the offsets are same as the previous
> version, so instead of adding CPSW version number in the driver, make the driver
> to fall through to the latest versions so that the new version of CPSW which has
> the same register offsets will work directly without patching the driver.
> 
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
> Reviewed-by: Felipe Balbi <balbi@ti.com>

Like others, I really think you should check the version explicitly.

Please respin this patch so that it supports new IP versions in that
way.

Thanks.
