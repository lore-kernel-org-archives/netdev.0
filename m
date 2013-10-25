From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH 3/4] sctp: fix some comments in associola.c
Date: Fri, 25 Oct 2013 19:43:20 -0400
Message-ID: <526B0218.2070809@gmail.com>
References: <1382665805-13952-1-git-send-email-wangweidong1@huawei.com> <1382665805-13952-4-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dingtianhong@huawei.com, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org
To: Wang Weidong <wangweidong1@huawei.com>, davem@davemloft.net,
	nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f171.google.com ([74.125.82.171]:52031 "EHLO
	mail-we0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751918Ab3JYXn1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Oct 2013 19:43:27 -0400
In-Reply-To: <1382665805-13952-4-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/24/2013 09:50 PM, Wang Weidong wrote:
> fix some spellings
>
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

-vlad

> ---
>   net/sctp/associola.c | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/net/sctp/associola.c b/net/sctp/associola.c
> index cef5099..c9b91cb 100644
> --- a/net/sctp/associola.c
> +++ b/net/sctp/associola.c
> @@ -602,7 +602,7 @@ void sctp_assoc_rm_peer(struct sctp_association *asoc,
>
>   		/* Start a T3 timer here in case it wasn't running so
>   		 * that these migrated packets have a chance to get
> -		 * retrnasmitted.
> +		 * retransmitted.
>   		 */
>   		if (!timer_pending(&active->T3_rtx_timer))
>   			if (!mod_timer(&active->T3_rtx_timer,
> @@ -665,7 +665,7 @@ struct sctp_transport *sctp_assoc_add_peer(struct sctp_association *asoc,
>   	/* Set the path max_retrans.  */
>   	peer->pathmaxrxt = asoc->pathmaxrxt;
>
> -	/* And the partial failure retrnas threshold */
> +	/* And the partial failure retrans threshold */
>   	peer->pf_retrans = asoc->pf_retrans;
>
>   	/* Initialize the peer's SACK delay timeout based on the
>
