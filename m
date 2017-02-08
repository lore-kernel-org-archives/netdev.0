From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCHv6 net-next 1/6] sctp: drop unnecessary __packed from some
 stream reconf structures
Date: Wed, 8 Feb 2017 19:56:19 -0200
Message-ID: <20170208215619.GH3414@localhost.localdomain>
References: <cover.1486573727.git.lucien.xin@gmail.com>
 <5f2d5aa54716217f68f724e4165289bd964b8755.1486573728.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41472 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750972AbdBHV4W (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 8 Feb 2017 16:56:22 -0500
Content-Disposition: inline
In-Reply-To: <5f2d5aa54716217f68f724e4165289bd964b8755.1486573728.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 09, 2017 at 01:18:15AM +0800, Xin Long wrote:
> commit 85c727b59483 ("sctp: drop __packed from almost all SCTP structures")
> has removed __packed from almost all SCTP structures. But there still are
> three structures where it should be dropped.
> 
> This patch is to remove it from some stream reconf structures.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

> ---
>  include/linux/sctp.h | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/sctp.h b/include/linux/sctp.h
> index 2408c68..d74fca3 100644
> --- a/include/linux/sctp.h
> +++ b/include/linux/sctp.h
> @@ -721,7 +721,7 @@ struct sctp_infox {
>  struct sctp_reconf_chunk {
>  	sctp_chunkhdr_t chunk_hdr;
>  	__u8 params[0];
> -} __packed;
> +};
>  
>  struct sctp_strreset_outreq {
>  	sctp_paramhdr_t param_hdr;
> @@ -729,12 +729,12 @@ struct sctp_strreset_outreq {
>  	__u32 response_seq;
>  	__u32 send_reset_at_tsn;
>  	__u16 list_of_streams[0];
> -} __packed;
> +};
>  
>  struct sctp_strreset_inreq {
>  	sctp_paramhdr_t param_hdr;
>  	__u32 request_seq;
>  	__u16 list_of_streams[0];
> -} __packed;
> +};
>  
>  #endif /* __LINUX_SCTP_H__ */
> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
