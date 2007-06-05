From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] UDP : bind() checks are not complete
Date: Tue, 05 Jun 2007 13:37:17 -0700 (PDT)
Message-ID: <20070605.133717.08652520.davem@davemloft.net>
References: <20070605191536.cc9a4719.dada1@cosmosbay.com>
	<20070605.130219.35356925.davem@davemloft.net>
	<4665C60C.1000406@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55606
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1764431AbXFEUhD convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jun 2007 16:37:03 -0400
In-Reply-To: <4665C60C.1000406@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 05 Jun 2007 22:22:36 +0200

> David Miller a =E9crit :
> > Does checking for INADDR_ANY sockets really require a full scan?
> > It should just need two hash probes as far as I can tell to see
> > if there is "0.0.0.0:PORT" bound already.
>=20
> Well, we might have 1000 ip addresses on the machine (or not :) ), an=
d
>=20
> 192.168.0.1:PORT ... 192.168.0.254:PORT already bound.

That's pretty serious.

Sadly, I think we'll have to revert.

