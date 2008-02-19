From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [Lksctp-developers] [PATCH][SCTP]: Pick up an orphaned	sctp_sockets_allocated
 counter.
Date: Tue, 19 Feb 2008 11:43:44 -0500
Message-ID: <47BB0740.2070104@hp.com>
References: <47BB05AA.6090101@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	lksctp-developers@lists.sourceforge.net
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:23965 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752765AbYBSQnd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2008 11:43:33 -0500
In-Reply-To: <47BB05AA.6090101@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov wrote:
> This counter is currently write-only.
> 
> Drawing an analogy with the similar tcp counter, I think
> that this one should be pointed by the sockets_allocated
> members of sctp_prot and sctpv6_prot.
> 
> Or should it be instead removed at all?
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Ack.  Looks like it got missed.  It should be added.

-vlad

> 
> ---
> 
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index d47d578..44797ad 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -6488,6 +6488,7 @@ struct proto sctp_prot = {
>  	.memory_pressure = &sctp_memory_pressure,
>  	.enter_memory_pressure = sctp_enter_memory_pressure,
>  	.memory_allocated = &sctp_memory_allocated,
> +	.sockets_allocated = &sctp_sockets_allocated,
>  	REF_PROTO_INUSE(sctp)
>  };
>  
> @@ -6521,6 +6522,7 @@ struct proto sctpv6_prot = {
>  	.memory_pressure = &sctp_memory_pressure,
>  	.enter_memory_pressure = sctp_enter_memory_pressure,
>  	.memory_allocated = &sctp_memory_allocated,
> +	.sockets_allocated = &sctp_sockets_allocated,
>  	REF_PROTO_INUSE(sctpv6)
>  };
>  #endif /* defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE) */
> 
> -------------------------------------------------------------------------
> This SF.net email is sponsored by: Microsoft
> Defy all challenges. Microsoft(R) Visual Studio 2008.
> http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
> _______________________________________________
> Lksctp-developers mailing list
> Lksctp-developers@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/lksctp-developers
> 

