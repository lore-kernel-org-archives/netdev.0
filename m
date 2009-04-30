From: reinette chatre <reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: iwlwifi: remove EXPORT_SYMBOL for static symbol
Date: Thu, 30 Apr 2009 10:21:59 -0700
Message-ID: <1241112119.10498.11.camel@rc-desk>
References: <m24ow6vah1.fsf@igel.home>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-MogPR669STc76Z2rM5mHXA@public.gmane.org" <netdev-MogPR669STc76Z2rM5mHXA@public.gmane.org>
To: Andreas Schwab <schwab-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <m24ow6vah1.fsf-hBGjKatGTSWzQB+pC5nmwQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2009-04-30 at 00:58 -0700, Andreas Schwab wrote:
> It does not make sense to apply EXPORT_SYMBOL to a static symbol.  Fixes
> this build error:
> 
> drivers/net/wireless/iwlwifi/iwl3945-base.c:1697: error: __ksymtab_iwl3945_rx_queue_reset causes a section type conflict
> 
> Signed-off-by: Andreas Schwab <schwab-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
> ---
> This obsoletes 6269b731560d69c5eaa929909891edec39496d71, which was

>From which repo is this commit id? 

> misattributed as a compiler bug.
> ---
>  drivers/net/wireless/iwlwifi/iwl3945-base.c |    1 -
>  1 file changed, 1 deletion(-)
> 
> --- linux-2.6.30-rc4.orig/drivers/net/wireless/iwlwifi/iwl3945-base.c	2009-04-30 08:59:41.000000000 +0200
> +++ linux-2.6.30-rc4/drivers/net/wireless/iwlwifi/iwl3945-base.c	2009-04-30 09:34:14.000000000 +0200
> @@ -1745,7 +1745,6 @@ static void iwl3945_rx_queue_free(struct
>  	rxq->bd = NULL;
>  	rxq->rb_stts  = NULL;
>  }
> -EXPORT_SYMBOL(iwl3945_rx_queue_free);
>  
> 
>  /* Convert linear signal-to-noise ratio into dB */
> 

Acked-by: Reinette Chatre <reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

Thank you

Reinette


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
