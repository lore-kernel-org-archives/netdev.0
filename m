From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next 9/9] net: sctp: sctp_ulpq: do not use char as a
 struct member
Date: Wed, 17 Apr 2013 11:45:52 -0400
Message-ID: <20130417154552.GJ5149@hmsreliant.think-freely.org>
References: <1366146438-8815-1-git-send-email-dborkman@redhat.com>
 <1366146438-8815-10-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53856 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965236Ab3DQPqJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 11:46:09 -0400
Content-Disposition: inline
In-Reply-To: <1366146438-8815-10-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 16, 2013 at 11:07:18PM +0200, Daniel Borkmann wrote:
> Replace char with a more appropriate __u8 bitfield for pd_mode.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>  include/net/sctp/ulpqueue.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/net/sctp/ulpqueue.h b/include/net/sctp/ulpqueue.h
> index 00e50ba..a2bebd4 100644
> --- a/include/net/sctp/ulpqueue.h
> +++ b/include/net/sctp/ulpqueue.h
> @@ -49,10 +49,10 @@
>  
>  /* A structure to carry information to the ULP (e.g. Sockets API) */
>  struct sctp_ulpq {
> -	char pd_mode;
>  	struct sctp_association *asoc;
>  	struct sk_buff_head reasm;
>  	struct sk_buff_head lobby;
> +	__u8 pd_mode:1;
>  };
>  

Can you move the char (or __u8 if you prefer) to right after the reasm meber?  I
think theres a hole there that you can fill in
Neil
