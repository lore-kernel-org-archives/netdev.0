From: Paul Moore <paul@paul-moore.com>
Subject: Re: [PATCH 05/16] netlabel: remove unnecessary break after goto
Date: Mon, 14 Jul 2014 18:30:58 -0400
Message-ID: <1736644.xDSijyH7JM@sifl>
References: <1405355467-7350-1-git-send-email-fabf@skynet.be> <1405355467-7350-6-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net, joe@perches.com,
	netdev@vger.kernel.org
To: Fabian Frederick <fabf@skynet.be>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405355467-7350-6-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday, July 14, 2014 06:30:55 PM Fabian Frederick wrote:
> Signed-off-by: Fabian Frederick <fabf@skynet.be>

Acked-by: Paul Moore <paul@paul-moore.com>

> ---
>  net/netlabel/netlabel_kapi.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/net/netlabel/netlabel_kapi.c b/net/netlabel/netlabel_kapi.c
> index 3045a96..fe9415e 100644
> --- a/net/netlabel/netlabel_kapi.c
> +++ b/net/netlabel/netlabel_kapi.c
> @@ -170,7 +170,6 @@ int netlbl_cfg_unlbl_map_add(const char *domain,
>  #endif /* IPv6 */
>  		default:
>  			goto cfg_unlbl_map_add_failure;
> -			break;
>  		}
> 
>  		entry->def.addrsel = addrmap;

-- 
paul moore
www.paul-moore.com
