From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: inet_add_protocol() can use cmpxchg()
Date: Thu, 9 Sep 2010 09:08:17 +0000
Message-ID: <20100909090816.GA7450@ff.dom.local>
References: <20100909064222.GA6951@ff.dom.local> <1284015345.2428.37.camel@edumazet-laptop> <20100909070926.GB6951@ff.dom.local> <20100909072453.GA7383@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, jesse@nicira.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:61051 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751085Ab0IIJIW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Sep 2010 05:08:22 -0400
Received: by bwz11 with SMTP id 11so921253bwz.19
        for <netdev@vger.kernel.org>; Thu, 09 Sep 2010 02:08:21 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20100909072453.GA7383@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 09, 2010 at 07:24:53AM +0000, Jarek Poplawski wrote:
> On Thu, Sep 09, 2010 at 07:09:26AM +0000, Jarek Poplawski wrote:
> > On Thu, Sep 09, 2010 at 08:55:45AM +0200, Eric Dumazet wrote:
> > > Le jeudi 09 septembre 2010 ?? 06:42 +0000, Jarek Poplawski a =E9c=
rit :
> > > > Of course, each case is different, but generally I understand J=
esse's
> > > > concern. Smaller data section argument shouldn't be enough. The=
re is
> > > > some reason we do it in C not asm, and there is some cost of
> > > > unreadable code too.
> > >=20
> > > Sure, but is cmpxchg() really not readable for you ? ;)
> >=20
> > Just like for Jesse: "this takes a little more thought". ;-)
>=20
> But more exactly, it's not about this one line, but the time you need
> when reading this after some time to tell: yes, this place is properl=
y
> locked for sure.

And most exactly, without "after some time" I couldn't tell this
either. Is seems some barriers might have been changed, but I might
be wrong. Anyway, it would be nice to have some comment on that in
the changelog.

Jarek P.
