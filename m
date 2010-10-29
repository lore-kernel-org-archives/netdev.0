From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 0/1] RFC: poll/select performance on datagram sockets
Date: Sat, 30 Oct 2010 00:08:12 +0200
Message-ID: <1288390092.2680.80.camel@edumazet-laptop>
References: <20101029191857.5f789d56@chocolatine.cbg.collabora.co.uk>
	 <1288380431.2680.3.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1010291306390.8517@davide-lnx1>
	 <alpine.DEB.2.00.1010291339180.8517@davide-lnx1>
	 <1288386348.2680.25.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1010291451330.8517@davide-lnx1>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alban Crequy <alban.crequy@collabora.co.uk>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Cyrill Gorcunov <gorcunov@openvz.org>,
	Alexey Dobriyan <adobriyan@gmail.com>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Pauli Nieminen <pauli.nieminen@collabora.co.uk>,
	Rainer Weikusat <rweikusat@mssgmbh.com>
To: Davide Libenzi <davidel@xmailserver.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:49525 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755031Ab0J2WIS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 18:08:18 -0400
In-Reply-To: <alpine.DEB.2.00.1010291451330.8517@davide-lnx1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 29 octobre 2010 =C3=A0 14:57 -0700, Davide Libenzi a =C3=A9=
crit :

> It is, though I am not sure that shuffling code around to chase false=
=20
> sharing on very specific cases, is an approach worth following.
> The new position of the table on the stack might share with another h=
ot=20
> line, under a different load.
>=20

Sure. Its only a start as I said. We should identify the shared portion
and make sure it sits in a dedicated cache line.



