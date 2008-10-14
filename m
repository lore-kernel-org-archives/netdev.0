From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pktgen: fix skb leak in case of failure
Date: Mon, 13 Oct 2008 18:45:49 -0700 (PDT)
Message-ID: <20081013.184549.251334267.davem@davemloft.net>
References: <Pine.LNX.4.64.0810131657250.3843@wrl-59.cs.helsinki.fi>
	<20081013170158.GA10494@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56512
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756012AbYJNBqN convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Oct 2008 21:46:13 -0400
In-Reply-To: <20081013170158.GA10494@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Mon, 13 Oct 2008 14:01:58 -0300

> Em Mon, Oct 13, 2008 at 05:22:18PM +0300, Ilpo J=E4rvinen escreveu:
> > Seems that skb goes into void unless something magic happened
> > in pskb_expand_head in case of failure.
> >=20
> > Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
>=20
> Good catch!
>=20
> Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Applied, thanks everyone.
