From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH v2] Add MSG_WAITFORONE flag to recvmmsg
Date: Sat, 27 Mar 2010 11:07:17 -0300
Message-ID: <20100327140717.GN3625@ghostprotocols.net>
References: <84621a61003261555q2c78f6a8o5b438113bed6bd2@mail.gmail.com> <a36005b51003261907x7ebe057bt2d541f63f20f632b@mail.gmail.com> <20100327021803.GA10866@xpc.home> <20100326.205428.44779758.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: blblack@gmail.com, netdev@vger.kernel.org, drepper@gmail.com,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3044 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753323Ab0C0OHX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Mar 2010 10:07:23 -0400
Content-Disposition: inline
In-Reply-To: <20100326.205428.44779758.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Fri, Mar 26, 2010 at 08:54:28PM -0700, David Miller escreveu:
> From: Brandon L Black <blblack@gmail.com>
> Date: Fri, 26 Mar 2010 21:18:03 -0500
> 
> > 
> > From: Brandon L Black <blblack@gmail.com>
> > 
> > Add new flag MSG_WAITFORONE for the recvmmsg() syscall.
> > When this flag is specified for a blocking socket, recvmmsg()
> > will only block until at least 1 packet is available.  The
> > default behavior is to block until all vlen packets are
> > available.  This flag has no effect on non-blocking sockets
> > or when used in combination with MSG_DONTWAIT.
> > 
> > Signed-off-by: Brandon L Black <blblack@gmail.com>
> 
> Arnaldo, please review this, thanks.

I'm ok with it.

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

- Arnaldo
