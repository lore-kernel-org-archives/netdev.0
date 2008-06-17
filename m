From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: sk->sk_socket
Date: Tue, 17 Jun 2008 11:14:39 -0300
Message-ID: <20080617141439.GB6970@ghostprotocols.net>
References: <20080617.032511.240272543.davem@davemloft.net> <20080617123254.GB25011@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:35877 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757715AbYFQOPE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 10:15:04 -0400
Content-Disposition: inline
In-Reply-To: <20080617123254.GB25011@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Tue, Jun 17, 2008 at 04:32:55PM +0400, Evgeniy Polyakov escreveu:
> On Tue, Jun 17, 2008 at 03:25:11AM -0700, David Miller (davem@davemloft.net) wrote:
> > For the curious, here are the only assignments to sk->sk_socket
> > remaining in the net-next-2.6 tree right now:
> > 
> > include/net/sock.h:	sk->sk_socket = NULL;
> > include/net/sock.h:	sk->sk_socket = parent;

Isn't this sock_graft and sock_orphan already? :)

> > net/core/sock.c:		newsk->sk_socket = NULL;
> > net/core/sock.c:	sk->sk_socket		=	sock;

I see, perhaps we can have __sock_orphan() in sk_clone() and
__sock_graft() in sock_init_data() 8)

- Arnaldo
