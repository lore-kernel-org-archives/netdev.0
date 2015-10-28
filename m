From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RESEND PATCH 07/10] net: wireless: iwlegacy: Remove unneeded
 variable ret
Date: Wed, 28 Oct 2015 16:35:13 +0300
Message-ID: <5630CF11.8080504@cogentembedded.com>
References: <1445972565-14963-1-git-send-email-punitvara@gmail.com>
 <1445972565-14963-7-git-send-email-punitvara@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ath10k-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Punit Vara <punitvara-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1445972565-14963-7-git-send-email-punitvara-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello.

On 10/27/2015 10:02 PM, Punit Vara wrote:

> This patch is to the 3945-mac.c file that fixes up following warning
> by coccicheck:
>
> drivers/net/wireless/iwlegacy/3945-mac.c:247:5-8: Unneeded variable:
> "ret". Return "- EOPNOTSUPP" on line 249
>
> Return -EOPNOTSUPP directly instead of return using ret
>
> Signed-off-by: Punit Vara <punitvara-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>   drivers/net/wireless/iwlegacy/3945-mac.c | 5 +----
>   1 file changed, 1 insertion(+), 4 deletions(-)
>
> diff --git a/drivers/net/wireless/iwlegacy/3945-mac.c b/drivers/net/wireless/iwlegacy/3945-mac.c
> index af1b3e6..ff4dc44 100644
> --- a/drivers/net/wireless/iwlegacy/3945-mac.c
> +++ b/drivers/net/wireless/iwlegacy/3945-mac.c
> @@ -244,9 +244,7 @@ il3945_set_dynamic_key(struct il_priv *il, struct ieee80211_key_conf *keyconf,
>   static int
>   il3945_remove_static_key(struct il_priv *il)
>   {
> -	int ret = -EOPNOTSUPP;
> -
> -	return ret;
> +	return -EOPNOTSUPP;
>   }
>
>   static int
> @@ -529,7 +527,6 @@ il3945_tx_skb(struct il_priv *il,
>   		if (unlikely(tid >= MAX_TID_COUNT))
>   			goto drop;
>   	}
> -

    Unrelated white space change.

MBR, Sergei

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
