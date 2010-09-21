From: Henrique de Moraes Holschuh <hmh@hmh.eng.br>
Subject: Re: [PATCH v3] ip: fix truesize mismatch in ip fragmentation
Date: Tue, 21 Sep 2010 15:09:40 -0300
Message-ID: <20100921180940.GA8754@khazad-dum.debian.net>
References: <20100920174443.GA5515@elliptictech.com>
 <1285006844.2323.17.camel@edumazet-laptop>
 <20100920195256.GA14330@elliptictech.com>
 <1285013853.2323.148.camel@edumazet-laptop>
 <1285018272.2323.243.camel@edumazet-laptop>
 <20100921140501.GA21572@elliptictech.com>
 <1285078613.2617.503.camel@edumazet-laptop>
 <1285084705.2617.636.camel@edumazet-laptop>
 <20100921162657.GA22183@khazad-dum.debian.net>
 <1285086679.2617.672.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nick Bowler <nbowler@elliptictech.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2.smtp.messagingengine.com ([66.111.4.26]:50388 "EHLO
	out2.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755668Ab0IUSJo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Sep 2010 14:09:44 -0400
Content-Disposition: inline
In-Reply-To: <1285086679.2617.672.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 21 Sep 2010, Eric Dumazet wrote:
> Le mardi 21 septembre 2010 =E0 13:26 -0300, Henrique de Moraes Holsch=
uh a
> =E9crit :
> > Should this be a candidate for -stable?
> >=20
>=20
> Yes, of course, but David wants to handle stable submissions himself.
>=20
> I am not sure we want to bug stable team with dozens of mails while
> polishing patches ?

We don't.  But one often marks commits that should go to -stable using =
a Cc:
pseudo-header, and also includes relevant information (e.g. to which st=
able
kernels it should be applied to) to the commit message.

Since there wasn't one, and I didn't readly find any post in this threa=
d
that mentioned it should also go to stable, AND it looked at first glan=
ce
like something that should go to stable, I asked about it.

--=20
  "One disk to rule them all, One disk to find them. One disk to bring
  them all and in the darkness grind them. In the Land of Redmond
  where the shadows lie." -- The Silicon Valley Tarot
  Henrique Holschuh
