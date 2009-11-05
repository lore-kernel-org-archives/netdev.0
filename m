From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC] [PATCH] udp: optimize lookup of UDP sockets to by including destination address in the hash key
Date: Thu, 5 Nov 2009 16:16:23 +0100
Message-ID: <20091105151623.GT31511@one.firstfloor.org>
References: <4AF1EC18.9090106@ixiacom.com> <4AF1F273.5020207@gmail.com> <200911050104.09538.opurdila@ixiacom.com> <4AF20F02.7000601@gmail.com> <877hu5892g.fsf@basil.nowhere.org> <4AF2CCD9.7010507@gmail.com> <20091105145428.GS31511@one.firstfloor.org> <4AF2EA2D.6040301@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andi Kleen <andi@firstfloor.org>,
	Octavian Purdila <opurdila@ixiacom.com>,
	Lucian Adrian Grijincu <lgrijincu@ixiacom.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:43475 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754058AbZKEPQS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2009 10:16:18 -0500
Content-Disposition: inline
In-Reply-To: <4AF2EA2D.6040301@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 05, 2009 at 04:07:25PM +0100, Eric Dumazet wrote:
> Andi Kleen a =E9crit :
> >> I assume cache is cold or even on other cpu (worst case), dealing =
with
> >> 100.000+ sockets or so...
> >=20
> > Other CPU cache hit is actually typically significantly=20
> > faster than a DRAM access (unless you're talking about a very large=
 NUMA=20
> > system and a remote CPU far away)
>=20
> Even if data is dirty in remote CPU cache ?=20

Some cache protocols have to force dirty data through DRAM, but modern
ones usually do not.

-Andi
