From: Steve deRosier <derosier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] ath6kl: fix spelling mistake: "Indicat" -> "Indicate"
Date: Sun, 4 Jun 2017 17:47:55 -0700
Message-ID: <CALLGbR+Bn4vXsQVYGTMy++rERu1O2JOHrGfekpo_aa86dLKsYQ@mail.gmail.com>
References: <20170604163608.24894-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
        linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Colin King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170604163608.24894-1-colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Jun 4, 2017 at 9:36 AM, Colin King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> wrote:
> From: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
>
> Trivial fix to spelling mistake in ath6kl_dbg debug message
>
> Signed-off-by: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> ---
>  drivers/net/wireless/ath/ath6kl/htc_pipe.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/wireless/ath/ath6kl/htc_pipe.c b/drivers/net/wireless/ath/ath6kl/htc_pipe.c
> index d127a08d60df..d4fd9e40fffb 100644
> --- a/drivers/net/wireless/ath/ath6kl/htc_pipe.c
> +++ b/drivers/net/wireless/ath/ath6kl/htc_pipe.c
> @@ -383,7 +383,7 @@ static enum htc_send_queue_result htc_try_send(struct htc_target *target,
>                         list_for_each_entry_safe(packet, tmp_pkt,
>                                                  txq, list) {
>                                 ath6kl_dbg(ATH6KL_DBG_HTC,
> -                                          "%s: Indicat overflowed TX pkts: %p\n",
> +                                          "%s: Indicate overflowed TX pkts: %p\n",
>                                            __func__, packet);
>                                 action = ep->ep_cb.tx_full(ep->target, packet);
>                                 if (action == HTC_SEND_FULL_DROP) {
> --
> 2.11.0
>

Looks good to me.

Reviewed-by: Steve deRosier <derosier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

- Steve
