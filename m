From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH v2 3/4] drivers: net: cpsw: use of_platform_depopulate()
Date: Fri, 29 Jul 2016 14:06:29 +0530
Message-ID: <586a36bd-3fa7-c602-d7c5-fd09e184b21f@ti.com>
References: <20160728175037.22053-1-grygorii.strashko@ti.com>
 <20160728175037.22053-4-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
	<linux-omap@vger.kernel.org>
To: Grygorii Strashko <grygorii.strashko@ti.com>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160728175037.22053-4-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 28 July 2016 11:20 PM, Grygorii Strashko wrote:
> Use of_platform_depopulate() in cpsw_remove() instead of
> of_device_unregister(), because CSPW child devices will not be
> recreated otherwise on next insmod. of_platform_depopulate() is
> correct way now as it will ensure that all steps done in
> of_platform_populate() are reverted, including cleaning up of
> OF_POPULATED flag.
> 
> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>

Reviewed-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
