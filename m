From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] sctp: Fix spelling mistake: "Atempt" -> "Attempt"
Date: Wed, 11 Jan 2017 09:39:44 -0500
Message-ID: <20170111143944.GC1518@hmswarspite.think-freely.org>
References: <20170110225306.14880-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vyasevich@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170110225306.14880-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 10, 2017 at 10:53:06PM +0000, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> Trivial fix to spelling mistake in WARN_ONCE message
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>  net/sctp/outqueue.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
> index e540826..34efaa4 100644
> --- a/net/sctp/outqueue.c
> +++ b/net/sctp/outqueue.c
> @@ -1048,7 +1048,7 @@ static void sctp_outq_flush(struct sctp_outq *q, int rtx_timeout, gfp_t gfp)
>  			     (new_transport->state == SCTP_PF)))
>  				new_transport = asoc->peer.active_path;
>  			if (new_transport->state == SCTP_UNCONFIRMED) {
> -				WARN_ONCE(1, "Atempt to send packet on unconfirmed path.");
> +				WARN_ONCE(1, "Attempt to send packet on unconfirmed path.");
>  				sctp_chunk_fail(chunk, 0);
>  				sctp_chunk_free(chunk);
>  				continue;
> -- 
> 2.10.2
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
