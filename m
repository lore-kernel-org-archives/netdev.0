From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Linux TCP's Robustness to Multipath Packet Reordering
Date: Tue, 26 Apr 2011 22:43:42 +0200
Message-ID: <1303850622.2699.6.camel@edumazet-laptop>
References: <BANLkTimpgXCpweZKCihCQkLjSZw5zL4=Pg@mail.gmail.com>
	 <1303730701.2747.110.camel@edumazet-laptop>
	 <BANLkTi=xns1Gdjyt-SX3yDETSQfO23rXXg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Carsten Wolff <carsten@wolffcarsten.de>, netdev@vger.kernel.org
To: Dominik Kaspar <dokaspar.ietf@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:35253 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753389Ab1DZUnr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 16:43:47 -0400
Received: by wya21 with SMTP id 21so781290wya.19
        for <netdev@vger.kernel.org>; Tue, 26 Apr 2011 13:43:46 -0700 (PDT)
In-Reply-To: <BANLkTi=xns1Gdjyt-SX3yDETSQfO23rXXg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 25 avril 2011 =C3=A0 16:35 +0200, Dominik Kaspar a =C3=A9crit =
:

> For the experiments, all default TCP options were used, meaning that
> SACK, DSACK, Timestamps, were all enabled. Not sure how to turn on/of=
f
> TSO... so that is probably enabled, too. Path emulation is done with
> tc/netem at the receiver interfaces (eth1, eth2) with this script:
>=20
> http://home.simula.no/~kaspar/static/netem.sh
>=20

What are the exact parameters ? (queue size for instance)

It would be nice to give detailed stats after one run, on receiver
(since you have netem on ingress side)

tc -s -d qdisc


