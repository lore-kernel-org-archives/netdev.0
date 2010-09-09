From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: inet_add_protocol() can use cmpxchg()
Date: Thu, 9 Sep 2010 07:24:53 +0000
Message-ID: <20100909072453.GA7383@ff.dom.local>
References: <20100909064222.GA6951@ff.dom.local> <1284015345.2428.37.camel@edumazet-laptop> <20100909070926.GB6951@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, jesse@nicira.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:36435 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750870Ab0IIHY7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Sep 2010 03:24:59 -0400
Received: by bwz11 with SMTP id 11so869710bwz.19
        for <netdev@vger.kernel.org>; Thu, 09 Sep 2010 00:24:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20100909070926.GB6951@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 09, 2010 at 07:09:26AM +0000, Jarek Poplawski wrote:
> On Thu, Sep 09, 2010 at 08:55:45AM +0200, Eric Dumazet wrote:
> > Le jeudi 09 septembre 2010 ?? 06:42 +0000, Jarek Poplawski a =E9cri=
t :
> > > Of course, each case is different, but generally I understand Jes=
se's
> > > concern. Smaller data section argument shouldn't be enough. There=
 is
> > > some reason we do it in C not asm, and there is some cost of
> > > unreadable code too.
> >=20
> > Sure, but is cmpxchg() really not readable for you ? ;)
>=20
> Just like for Jesse: "this takes a little more thought". ;-)

But more exactly, it's not about this one line, but the time you need
when reading this after some time to tell: yes, this place is properly
locked for sure.

Jarek P.
