From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] dont create cached routes from ARP requests
Date: Thu, 23 Sep 2010 17:05:02 +0200
Message-ID: <1285254302.2509.47.camel@edumazet-laptop>
References: <20100922162209.GA10281@babylon>
	 <20100922.203442.233700254.davem@davemloft.net>
	 <20100923144708.GA8037@babylon>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ulrich Weber <uweber@astaro.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:38038 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754136Ab0IWPFH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 11:05:07 -0400
Received: by fxm3 with SMTP id 3so98161fxm.19
        for <netdev@vger.kernel.org>; Thu, 23 Sep 2010 08:05:06 -0700 (PDT)
In-Reply-To: <20100923144708.GA8037@babylon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 23 septembre 2010 =C3=A0 16:47 +0200, Ulrich Weber a =C3=A9cri=
t :
> On Wed, Sep 22, 2010 at 08:34:42PM -0700, David Miller wrote:
> > From: Ulrich Weber <uweber@astaro.com>
> > Date: Wed, 22 Sep 2010 18:22:09 +0200
> >=20
> > > Background: At home I have two Internet connections, DSL and Cabl=
e.
> > > DSL is the primary uplink while Cable is the secondary.
> > > My Cable ISP is flooding me with ARP request from 10.0.0.0/8,
> > > which creates routes via the primary uplink.
> > > There are thousands of cached routes and after some time
> > > I get "Neighbour table overflow" messages.
> >=20
> > If you get neighbour table overflows, something is holding a refere=
nce
> > to the routing cache entry and/or the neighbour entries those routi=
ng
> > cache entries are attached to.
> >=20
> > If these really are transient entries, they should be trivially
> > garbage collected and not cause any problems at all.
> rt_garbage_collect is not called within rt_intern_hash,
> because the call is done within softirq context.
>=20
> Forcing the call of rt_garbage_collect didn't help either,
> there are no routes freed afterwards...
>=20

Please give us more information.

grep . /proc/sys/net/ipv4/route/*

rtstat -c10 -i1

Thanks


