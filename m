From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: SO_TIMESTAMP implementation for TCP
Date: Sat, 01 May 2010 08:00:48 +0200
Message-ID: <1272693648.2230.78.camel@edumazet-laptop>
References: <alpine.DEB.1.00.1004292246440.12776@pokey.mtv.corp.google.com>
	 <20100429.233958.212393607.davem@davemloft.net>
	 <i2i65634d661004300058s5ee1b177oee249d3d22baad62@mail.gmail.com>
	 <20100430.164115.257514715.davem@davemloft.net>
	 <20100501010735.dfe097bc.billfink@mindspring.com>
	 <AANLkTimFjDNgXdMGpVpO7Gi38ROlww1Fa7IKA1ASBKOV@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Bill Fink <billfink@mindspring.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:52639 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750955Ab0EAGAz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 May 2010 02:00:55 -0400
Received: by bwz19 with SMTP id 19so481764bwz.21
        for <netdev@vger.kernel.org>; Fri, 30 Apr 2010 23:00:53 -0700 (PDT)
In-Reply-To: <AANLkTimFjDNgXdMGpVpO7Gi38ROlww1Fa7IKA1ASBKOV@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 30 avril 2010 =C3=A0 22:40 -0700, Tom Herbert a =C3=A9crit =
:
> > Not being a kernel hacker, I will naively ask if the kernel tracing
> > facility could somehow be used to provide the desired info (or coul=
d
> > be modified to provide it).
> >
>=20
> We did consider kernel tracing (more in the context of implementing
> RFC 4898).  In the case of trying get per packet timestamps,
> correlating a ktrace event with an application message is probably to=
o
> high to make it practical.  If it weren't for the cost of
> timestamp'ing every single skb being received, we'd probably have
> SO_TIMESTAMP turned on permanently for many connections.  For now
> we're settling for a percentage of messages for sampling.

Tom, did you tried to reuse existing skb or sk tstamps ?



