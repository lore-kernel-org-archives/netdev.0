From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: RFC 3484 support
Date: Fri, 14 Nov 2003 01:29:09 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0311140127410.14460-100000@netcore.fi>
References: <3FB41109.60902@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kuznet@ms2.inr.ac.ru, <netdev@oss.sgi.com>, <yoshfuji@linux-ipv6.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ulrich Drepper <drepper@redhat.com>
In-Reply-To: <3FB41109.60902@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 13 Nov 2003, Ulrich Drepper wrote:
> > Currently getaddrinfo picks the destination address in a round-robin 
> > fashion.
> 
> That's what could be done but isn't since I see little value.  We
> currently return IPv6 address, if there are any and if they are wanted,
> first, then the IPv4 addresses.  The order in which multiple IPv6 and/or
> IPv4 addresses are returned depends on the order the server returns it
> and eventually on artificial round-robin selection.

Oops, sorry.  That's what I meant.  The current behaviour is good.  
Putting v6 first is regular practice and good.
 
-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
