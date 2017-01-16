From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net-next] sctp: remove unused var from sctp_process_asconf
Date: Mon, 16 Jan 2017 22:40:28 +0800
Message-ID: <CADvbK_dd_DFqWUX9B3+ymA5GJKk4H2BJTbmZyu5uqqV65ajghg@mail.gmail.com>
References: <5da2cda90a7489b22ae98703d7543c5316bae375.1484336552.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:34216 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750919AbdAPOka (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 09:40:30 -0500
In-Reply-To: <5da2cda90a7489b22ae98703d7543c5316bae375.1484336552.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 14, 2017 at 4:27 AM, Marcelo Ricardo Leitner
<marcelo.leitner@gmail.com> wrote:
> Assigned but not used.
>
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Reviewed-by: Xin Long <lucien.xin@gmail.com>

> ---
>  net/sctp/sm_make_chunk.c | 2 --
>  1 file changed, 2 deletions(-)
>
> diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
> index a15d824a313d310ed03ba77055d22b1c7c9d0662..80a9088084ac0d1116bf983fad9a0cdfddeefe44 100644
> --- a/net/sctp/sm_make_chunk.c
> +++ b/net/sctp/sm_make_chunk.c
> @@ -3210,7 +3210,6 @@ struct sctp_chunk *sctp_process_asconf(struct sctp_association *asoc,
>         union sctp_params param;
>         sctp_addiphdr_t         *hdr;
>         union sctp_addr_param   *addr_param;
> -       sctp_addip_param_t      *asconf_param;
>         struct sctp_chunk       *asconf_ack;
>         __be16  err_code;
>         int     length = 0;
> @@ -3230,7 +3229,6 @@ struct sctp_chunk *sctp_process_asconf(struct sctp_association *asoc,
>          * asconf parameter.
>          */
>         length = ntohs(addr_param->p.length);
> -       asconf_param = (void *)addr_param + length;
>         chunk_len -= length;
>
>         /* create an ASCONF_ACK chunk.
> --
> 2.9.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
