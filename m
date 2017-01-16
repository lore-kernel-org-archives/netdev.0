From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next] sctp: remove unused var from sctp_process_asconf
Date: Mon, 16 Jan 2017 08:13:47 -0500
Message-ID: <20170116131347.GA30105@hmswarspite.think-freely.org>
References: <5da2cda90a7489b22ae98703d7543c5316bae375.1484336552.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        Vlad Yasevich <vyasevich@gmail.com>
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:42729 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751096AbdAPNOu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 08:14:50 -0500
Content-Disposition: inline
In-Reply-To: <5da2cda90a7489b22ae98703d7543c5316bae375.1484336552.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 13, 2017 at 06:27:33PM -0200, Marcelo Ricardo Leitner wrote:
> Assigned but not used.
> 
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> ---
>  net/sctp/sm_make_chunk.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
> index a15d824a313d310ed03ba77055d22b1c7c9d0662..80a9088084ac0d1116bf983fad9a0cdfddeefe44 100644
> --- a/net/sctp/sm_make_chunk.c
> +++ b/net/sctp/sm_make_chunk.c
> @@ -3210,7 +3210,6 @@ struct sctp_chunk *sctp_process_asconf(struct sctp_association *asoc,
>  	union sctp_params param;
>  	sctp_addiphdr_t		*hdr;
>  	union sctp_addr_param	*addr_param;
> -	sctp_addip_param_t	*asconf_param;
>  	struct sctp_chunk	*asconf_ack;
>  	__be16	err_code;
>  	int	length = 0;
> @@ -3230,7 +3229,6 @@ struct sctp_chunk *sctp_process_asconf(struct sctp_association *asoc,
>  	 * asconf parameter.
>  	 */
>  	length = ntohs(addr_param->p.length);
> -	asconf_param = (void *)addr_param + length;
>  	chunk_len -= length;
>  
>  	/* create an ASCONF_ACK chunk.
> -- 
> 2.9.3
> 
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
