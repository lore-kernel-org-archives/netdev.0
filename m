From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next 5/9] net: sctp: outqueue: simplify
 sctp_outq_uncork function
Date: Wed, 17 Apr 2013 11:32:57 -0400
Message-ID: <20130417153257.GF5149@hmsreliant.think-freely.org>
References: <1366146438-8815-1-git-send-email-dborkman@redhat.com>
 <1366146438-8815-6-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53404 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964900Ab3DQPdC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 11:33:02 -0400
Content-Disposition: inline
In-Reply-To: <1366146438-8815-6-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 16, 2013 at 11:07:14PM +0200, Daniel Borkmann wrote:
> Just a minor edit to simplify the function. No need for this
> error variable here.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>  net/sctp/outqueue.c | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
> index d4c137e..32a4625 100644
> --- a/net/sctp/outqueue.c
> +++ b/net/sctp/outqueue.c
> @@ -701,11 +701,10 @@ redo:
>  /* Cork the outqueue so queued chunks are really queued. */
>  int sctp_outq_uncork(struct sctp_outq *q)
>  {
> -	int error = 0;
>  	if (q->cork)
>  		q->cork = 0;
> -	error = sctp_outq_flush(q, 0);
> -	return error;
> +
> +	return sctp_outq_flush(q, 0);
>  }
>  
>  
> -- 
> 1.7.11.7
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
