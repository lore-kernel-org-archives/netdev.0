From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: AF_UNIX MSG_PEEK bug?
Date: Wed, 9 Jan 2008 19:05:56 -0800
Message-ID: <20080109190556.468cbd6c@deepthought>
References: <E1JCkrp-0000vX-00@gondolin.me.apana.org.au>
	<alpine.BSF.1.00.0801092031290.35527@pkunk.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Brent Casavant <bcasavan@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:38910 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754655AbYAJDIN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jan 2008 22:08:13 -0500
In-Reply-To: <alpine.BSF.1.00.0801092031290.35527@pkunk.americas.sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index 060bba4..2ffdf5b 100644
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
> @@ -50,6 +50,9 @@
>   *	     Arnaldo C. Melo	:	Remove MOD_{INC,DEC}_USE_COUNT,
>   *	     				the core infrastructure is doing that
>   *	     				for all net proto families now (2.5.69+)
> + *		Brent Casavant	:	SOCK_STREAM MSG_PEEK should peek
> + *					far enough ahead to satisfy the request
> + *					rather than stop after the first skb.
>   *
>   *

The kernel doesn't use comments as a changlog anymore, that was so last century.


-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>
