From: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH] net/sunrpc/auth_gss/gss_krb5_crypto.c: Use normal
 negative error value return
Date: Tue, 14 Dec 2010 16:19:22 -0500
Message-ID: <20101214211922.GJ24828@fieldses.org>
References: <1289786891.16461.102.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>,
	Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1289786891.16461.102.camel@Joe-Laptop>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 14, 2010 at 06:08:11PM -0800, Joe Perches wrote:
> And remove unnecessary double semicolon too.
> 
> No effect to code, as test is != 0.

Hm, the error return's actually ignored.  But OK.  Applying to my tree
for 2.6.38 assuming nobody else has picked it up.

--b.

> 
> Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
> ---
>  net/sunrpc/auth_gss/gss_krb5_crypto.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/sunrpc/auth_gss/gss_krb5_crypto.c b/net/sunrpc/auth_gss/gss_krb5_crypto.c
> index 75ee993..9576f35 100644
> --- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
> +++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
> @@ -137,7 +137,7 @@ arcfour_hmac_md5_usage_to_salt(unsigned int usage, u8 salt[4])
>  		ms_usage = 13;
>  		break;
>  	default:
> -		return EINVAL;;
> +		return -EINVAL;
>  	}
>  	salt[0] = (ms_usage >> 0) & 0xff;
>  	salt[1] = (ms_usage >> 8) & 0xff;
> 
> 
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
