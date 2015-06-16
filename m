From: Phil Sutter <phil@nwl.cc>
Subject: Re: netstat and dual stack sockets
Date: Tue, 16 Jun 2015 03:25:53 +0200
Message-ID: <20150616012538.05160213DD@mail.nwl.cc>
References: <20150615205421.GA22616@orbit.nwl.cc>
 <CAPh34mdX2YuqMVY8Adjnaa4CET2xaMJafQ2mLgck6sOo0Nq3xQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:54254 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755843AbbFPBZj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jun 2015 21:25:39 -0400
Content-Disposition: inline
In-Reply-To: <CAPh34mdX2YuqMVY8Adjnaa4CET2xaMJafQ2mLgck6sOo0Nq3xQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

HGN!

On Mon, Jun 15, 2015 at 11:36:54PM +0200, Hagen Paul Pfeifer wrote:
> On 15 June 2015 at 22:54, Phil Sutter <phil@nwl.cc> wrote:
> 
> > As I see it, a user has no way of detecting the listening socket in this
> > address family: it does not show in /proc/net/{tcp,udp} nor do
> > 'netstat', 'ss' or 'lsof' print any additional information about those
> > sockets over pure IPv6 ones.
> 
> Probably a combination of IPV6_V6ONLY(1, 0) and IN6_IS_ADDR_V4MAPPED
> fulfills all user requirements, ... so far. Your proposal is to hand
> over sk->sk_ipv6only?

Not sure if I understand you correctly - of course it is possible to
programmatically determine whether a socket one has opened accepts
v4mapped addresses or a given address is v4mapped. My concern is about
the system administrator's point of view, using system tools to find out
on which IP addresses and ports a machine is accessible. Looking at e.g.
/proc/net/tcp6 does not reveal if a listening socket also accepts
v4mapped addresses, factually acting as AF_INET socket upon request.

Cheers, Phil
