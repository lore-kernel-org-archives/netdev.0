From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] tcp: allow effective reduction of TCP's rcv-buffer via  setsockopt
Date: Thu, 19 Aug 2010 08:58:46 +0200
Message-ID: <62cfdf78ab776307fb132a5c8fde128e@localhost>
References: <1281900976-11852-1-git-send-email-hagen@jauu.net>
 <20100818.233337.52187393.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <kaber@trash.net>,
	<eric.dumazet@gmail.com>, <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:52555 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750999Ab0HSG6s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 02:58:48 -0400
In-Reply-To: <20100818.233337.52187393.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 18 Aug 2010 23:33:37 -0700 (PDT), David Miller wrote:

> From: Hagen Paul Pfeifer <hagen@jauu.net>

> Date: Sun, 15 Aug 2010 21:36:16 +0200

> 

>> +

>> +		if (sk->sk_userlocks & SOCK_RCVBUF_LOCK &&

>> +				(req->window_clamp > tcp_full_space(sk) || req->window_clamp ==

0))

>> +			req->window_clamp = tcp_full_space(sk);

>> +

> 

> Logically the patch looks fine, but please fix the indentation of the

> second line of the two new if() statements in this patch, the

> second line's first character should line up with the character

> right after the openning "(" on the previous line.



Sorry Dave, I played with my vim settings ... I will resubmit the patch.

;-)
