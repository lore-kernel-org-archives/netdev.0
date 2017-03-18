From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net] sctp: define dst_pending_confirm as a bit in
 sctp_transport
Date: Sat, 18 Mar 2017 15:07:08 -0400
Message-ID: <20170318190708.GB14004@neilslaptop.think-freely.org>
References: <b4390881b14adce583817529e5d58599acb5a8ee.1489836443.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vlad Yasevich <vyasevich@gmail.com>, ja@ssi.bg
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:42558 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751685AbdCRTHW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 18 Mar 2017 15:07:22 -0400
Content-Disposition: inline
In-Reply-To: <b4390881b14adce583817529e5d58599acb5a8ee.1489836443.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 18, 2017 at 07:27:23PM +0800, Xin Long wrote:
> As tp->dst_pending_confirm's value can only be set 0 or 1, this
> patch is to change to define it as a bit instead of __u32.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---
>  include/net/sctp/structs.h | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
> index 07a0b12..4f64519 100644
> --- a/include/net/sctp/structs.h
> +++ b/include/net/sctp/structs.h
> @@ -753,6 +753,8 @@ struct sctp_transport {
>  		/* Is the Path MTU update pending on this tranport */
>  		pmtu_pending:1,
>  
> +		dst_pending_confirm:1,	/* need to confirm neighbour */
> +
>  		/* Has this transport moved the ctsn since we last sacked */
>  		sack_generation:1;
>  	u32 dst_cookie;
> @@ -806,8 +808,6 @@ struct sctp_transport {
>  
>  	__u32 burst_limited;	/* Holds old cwnd when max.burst is applied */
>  
> -	__u32 dst_pending_confirm;	/* need to confirm neighbour */
> -
>  	/* Destination */
>  	struct dst_entry *dst;
>  	/* Source address. */
> -- 
> 2.1.0
> 
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
