From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2 net-next] tcp: remove one indentation level in
 tcp_rcv_state_process()
Date: Thu, 23 May 2013 10:09:41 -0700
Message-ID: <1369328981.2075.16.camel@joe-AO722>
References: <1366341367.3205.85.camel@edumazet-glaptop>
	 <1369324525.3301.384.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:44783 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757737Ab3EWRJo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 May 2013 13:09:44 -0400
In-Reply-To: <1369324525.3301.384.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-05-23 at 08:55 -0700, Eric Dumazet wrote:
> Remove one level of indentation 'introduced' in commit
> c3ae62af8e75 (tcp: should drop incoming frames without ACK flag set)
[]
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
[]
> -				if (sk->sk_socket)
> -					sk_wake_async(sk,
> -						      SOCK_WAKE_IO, POLL_OUT);
[]
> +			if (sk->sk_socket)
> +				sk_wake_async(sk,
> +					      SOCK_WAKE_IO, POLL_OUT);

It'd also be nice to reflow the lines to 80 cols.

				sk_wake_async(sk, SOCK_WAKE_IO, POLL_OUT);
