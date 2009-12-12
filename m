From: lists@nerdbynature.de
Subject: Re: Badness at net/ipv4/inet_connection_sock.c:293
Date: Sat, 12 Dec 2009 02:06:14 -0800 (PST)
Message-ID: <alpine.DEB.2.01.0912120203020.2915@bogon.housecafe.de>
References: <alpine.DEB.2.01.0912112335440.2915@bogon.housecafe.de> <20091212.010340.227842186.davem@davemloft.net> <4B2360BF.5000102@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761391AbZLLKGW@vger.kernel.org>
In-Reply-To: <4B2360BF.5000102@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 12 Dec 2009 at 10:22, Eric Dumazet wrote:
> > Yeah I started seeing this on one of my machines too, the
> > assertion is:
> > 
> > 	WARN_ON(newsk->sk_state == TCP_SYN_RECV);
> > 
> > I wonder if some of the refactorings we did to allow per-route
> > SACK/DSACK/etc. controls messed some sequence of state changes
> > on TCP sockets.  But I can't find anything obvious in those
> > commits.
> 
> Could it be about syncookies patches ?
> tcp_create_openreq_child() changes ?

Hm, I'd like to reproduce this thing and just ran "siege" against the 
proxy, spawning > 10k connections (simliar to when the warnings appeared) 
but I can't trigger the message any more. I'm tempted to bisect, but this 
is no fun when I cannot reproduce the messages :-\

Christian.
-- 
BOFH excuse #140:

LBNC (luser brain not connected)
