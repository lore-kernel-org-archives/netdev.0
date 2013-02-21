From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] sunrpc/auth_gss: fix sparse warnings for gss_mech_switch
Date: Thu, 21 Feb 2013 18:15:11 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9235DA5BB@SACEXCMBX04-PRD.hq.netapp.com>
References: <1361470206-24116-1-git-send-email-silviupopescu1990@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bfields@fieldses.org" <bfields@fieldses.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1361470206-24116-1-git-send-email-silviupopescu1990@gmail.com>
Content-Language: en-US
Content-ID: <EB77E0E59E5E93438E89B9D3A559A5F4@tahoe.netapp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-02-21 at 20:10 +0200, Silviu-Mihai Popescu wrote:
> This fixes the following sparse warnings:
> 	* net/sunrpc/auth_gss/gss_mech_switch.c:143:21: warning: symbol
> '_gss_mech_get_by_name' was not declared. Should it be static?
> 	* net/sunrpc/auth_gss/gss_mech_switch.c:208:21: warning: symbol
> '_gss_mech_get_by_pseudoflavor' was not declared. Should it be static?
> 
> Signed-off-by: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
> ---
>  net/sunrpc/auth_gss/gss_mech_switch.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sunrpc/auth_gss/gss_mech_switch.c b/net/sunrpc/auth_gss/gss_mech_switch.c
> index b174fcd..f0f4eee 100644
> --- a/net/sunrpc/auth_gss/gss_mech_switch.c
> +++ b/net/sunrpc/auth_gss/gss_mech_switch.c
> @@ -140,7 +140,7 @@ gss_mech_get(struct gss_api_mech *gm)
>  
>  EXPORT_SYMBOL_GPL(gss_mech_get);
>  
> -struct gss_api_mech *
> +static struct gss_api_mech *
>  _gss_mech_get_by_name(const char *name)
>  {
>  	struct gss_api_mech	*pos, *gm = NULL;
> @@ -205,7 +205,7 @@ mech_supports_pseudoflavor(struct gss_api_mech *gm, u32 pseudoflavor)
>  	return 0;
>  }
>  
> -struct gss_api_mech *_gss_mech_get_by_pseudoflavor(u32 pseudoflavor)
> +static struct gss_api_mech *_gss_mech_get_by_pseudoflavor(u32 pseudoflavor)
>  {
>  	struct gss_api_mech *gm = NULL, *pos;
>  

This is identical to commit c5f5e9c5d2e9178fb0bfe4f44f0afcc8ad6488ef
(SUNRPC: Add missing static declaration to _gss_mech_get_by_name) which
is already upstream.

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
