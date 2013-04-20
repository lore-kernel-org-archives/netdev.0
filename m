From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH net] irda: irlmp_reasons[] can be static
Date: Sat, 20 Apr 2013 14:11:51 +0300
Message-ID: <20130420111151.GE26896@mwanda>
References: <5171ea81.dFNn973/RcdmuuQR%fengguang.wu@intel.com>
 <20130420031045.GC7366@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Fengguang Wu <fengguang.wu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:30315 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754834Ab3DTLMD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Apr 2013 07:12:03 -0400
Content-Disposition: inline
In-Reply-To: <20130420031045.GC7366@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 20, 2013 at 11:10:45AM +0800, Fengguang Wu wrote:
> Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
> ---
>  irlmp.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/irda/irlmp.c b/net/irda/irlmp.c
> index 1064621..98ad6ec 100644
> --- a/net/irda/irlmp.c
> +++ b/net/irda/irlmp.c
> @@ -58,7 +58,7 @@ int  sysctl_discovery_slots   = 6; /* 6 slots by default */
>  int  sysctl_lap_keepalive_time = LM_IDLE_TIMEOUT * 1000 / HZ;
>  char sysctl_devname[65];
>  
> -const char *irlmp_reasons[] = {
> +static const char *irlmp_reasons[] = {

Oops.  Sorry for that.  I do run Sparse on my patches but I missed
that.

Acked-by: Dan Carpenter <dan.carpenter@oracle.com>

regards,
dan carpenter
