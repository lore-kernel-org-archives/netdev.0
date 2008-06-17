From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: sk->sk_socket
Date: Tue, 17 Jun 2008 16:32:55 +0400
Message-ID: <20080617123254.GB25011@2ka.mipt.ru>
References: <20080617.032511.240272543.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:55433 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755749AbYFQMdN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 08:33:13 -0400
Content-Disposition: inline
In-Reply-To: <20080617.032511.240272543.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 17, 2008 at 03:25:11AM -0700, David Miller (davem@davemloft.net) wrote:
> For the curious, here are the only assignments to sk->sk_socket
> remaining in the net-next-2.6 tree right now:
> 
> include/net/sock.h:	sk->sk_socket = NULL;
> include/net/sock.h:	sk->sk_socket = parent;
> net/core/sock.c:		newsk->sk_socket = NULL;
> net/core/sock.c:	sk->sk_socket		=	sock;

Screams for helper function? :)

-- 
	Evgeniy Polyakov
