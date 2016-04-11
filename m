From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH 0/2] drivers: net: cpsw: fix ale calls and drop host_port
 field from cpsw_priv
Date: Mon, 11 Apr 2016 14:06:14 +0530
Message-ID: <570B61FE.1020206@ti.com>
References: <1460031404-28594-1-git-send-email-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
	<linux-omap@vger.kernel.org>
To: Grygorii Strashko <grygorii.strashko@ti.com>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1460031404-28594-1-git-send-email-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 07 April 2016 05:46 PM, Grygorii Strashko wrote:
> This clean up series intended to:
>  - fix port_mask parameters in ale calls and drop unnecessary shifts
>  - drop host_port field from struct cpsw_priv
> 
> Nothing critical. Tested on am437x-idk-evm in dual mac and switch modes.
> 
> Grygorii Strashko (2):
>   drivers: net: cpsw: fix port_mask parameters in ale calls
>   drivers: net: cpsw: drop host_port field from struct cpsw_priv
> 
>  drivers/net/ethernet/ti/cpsw.c | 52 +++++++++++++++++-------------------------
>  1 file changed, 21 insertions(+), 31 deletions(-)
> 

Reviewed-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
