From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net] sctp: declare struct sctp_stream before using it
Date: Mon, 20 Mar 2017 09:29:20 -0400
Message-ID: <20170320132920.GA7855@hmswarspite.think-freely.org>
References: <1a16b414118d0876373774654d86e2a2a936b9d1.1490003187.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:33280 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753039AbdCTNaX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 09:30:23 -0400
Content-Disposition: inline
In-Reply-To: <1a16b414118d0876373774654d86e2a2a936b9d1.1490003187.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 20, 2017 at 05:46:27PM +0800, Xin Long wrote:
> sctp_stream_free uses struct sctp_stream as a param, but struct sctp_stream
> is defined after it's declaration.
> 
> This patch is to declare struct sctp_stream before sctp_stream_free.
> 
> Fixes: a83863174a61 ("sctp: prepare asoc stream for stream reconf")
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---
>  include/net/sctp/structs.h | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
> index 4f64519..592dece 100644
> --- a/include/net/sctp/structs.h
> +++ b/include/net/sctp/structs.h
> @@ -83,6 +83,7 @@ struct sctp_bind_addr;
>  struct sctp_ulpq;
>  struct sctp_ep_common;
>  struct crypto_shash;
> +struct sctp_stream;
>  
>  
>  #include <net/sctp/tsnmap.h>
> -- 
> 2.1.0
> 
> 

Not sure I follow.  did we run into a compilation failure here?

Neil
