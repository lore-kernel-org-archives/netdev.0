From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] tcp: remove one indentation level in
 tcp_rcv_state_process()
Date: Thu, 23 May 2013 10:12:57 -0700
Message-ID: <1369329177.3301.391.camel@edumazet-glaptop>
References: <1366341367.3205.85.camel@edumazet-glaptop>
	 <1369324525.3301.384.camel@edumazet-glaptop>
	 <1369328981.2075.16.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:38281 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757953Ab3EWRM7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 May 2013 13:12:59 -0400
Received: by mail-pa0-f42.google.com with SMTP id bj3so3238055pad.15
        for <netdev@vger.kernel.org>; Thu, 23 May 2013 10:12:58 -0700 (PDT)
In-Reply-To: <1369328981.2075.16.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-05-23 at 10:09 -0700, Joe Perches wrote:
> On Thu, 2013-05-23 at 08:55 -0700, Eric Dumazet wrote:
> > Remove one level of indentation 'introduced' in commit
> > c3ae62af8e75 (tcp: should drop incoming frames without ACK flag set)
> []
> > diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> []
> > -				if (sk->sk_socket)
> > -					sk_wake_async(sk,
> > -						      SOCK_WAKE_IO, POLL_OUT);
> []
> > +			if (sk->sk_socket)
> > +				sk_wake_async(sk,
> > +					      SOCK_WAKE_IO, POLL_OUT);
> 
> It'd also be nice to reflow the lines to 80 cols.
> 
> 				sk_wake_async(sk, SOCK_WAKE_IO, POLL_OUT);
> 

ok will do.
