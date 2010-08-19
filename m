From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: allow effective reduction of TCP's rcv-buffer via
 setsockopt
Date: Wed, 18 Aug 2010 23:33:37 -0700 (PDT)
Message-ID: <20100818.233337.52187393.davem@davemloft.net>
References: <1281900976-11852-1-git-send-email-hagen@jauu.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, eric.dumazet@gmail.com,
	ilpo.jarvinen@helsinki.fi
To: hagen@jauu.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38424
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751066Ab0HSGdS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 02:33:18 -0400
In-Reply-To: <1281900976-11852-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hagen Paul Pfeifer <hagen@jauu.net>
Date: Sun, 15 Aug 2010 21:36:16 +0200

> +
> +		/* limit the window selection if the user enforce a smaller rx buffer */
> +		if (sk->sk_userlocks & SOCK_RCVBUF_LOCK &&
> +				(req->window_clamp > tcp_full_space(sk) || req->window_clamp == 0))
> +			req->window_clamp = tcp_full_space(sk);
> +

Logically the patch looks fine, but please fix the indentation of the
second line of the two new if() statements in this patch, the
second line's first character should line up with the character
right after the openning "(" on the previous line.

Thanks.
