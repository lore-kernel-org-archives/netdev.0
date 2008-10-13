From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH] pktgen: fix skb leak in case of failure
Date: Mon, 13 Oct 2008 14:01:58 -0300
Message-ID: <20081013170158.GA10494@ghostprotocols.net>
References: <Pine.LNX.4.64.0810131657250.3843@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:42608 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754947AbYJMRCN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Oct 2008 13:02:13 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0810131657250.3843@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Mon, Oct 13, 2008 at 05:22:18PM +0300, Ilpo J=E4rvinen escreveu:
> Seems that skb goes into void unless something magic happened
> in pskb_expand_head in case of failure.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Good catch!

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>
