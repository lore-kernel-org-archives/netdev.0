From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.23 take2] UDP: Cleanup UDP encapsulation code
Date: Tue, 10 Jul 2007 23:06:54 -0700 (PDT)
Message-ID: <20070710.230654.03111146.davem@davemloft.net>
References: <468D299E.5070902@katalix.com>
	<200707061055.17951.remi.denis-courmont@nokia.com>
	<468E444C.9070609@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: remi.denis-courmont@nokia.com, jchapman@katalix.com,
	netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33262
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755244AbXGKGeL convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2007 02:34:11 -0400
In-Reply-To: <468E444C.9070609@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Patrick McHardy <kaber@trash.net>
Date: Fri, 06 Jul 2007 15:31:56 +0200

> R=E9mi Denis-Courmont wrote:
> > On Thursday 05 July 2007 20:25:50 ext James Chapman wrote:
> >=20
> >>R=E9mi Denis-Courmont wrote:
> >>
> >>>By the way, couldn't encap_type be remove altogether (using two sl=
ightly
> >>>different callbacks for ESP) from udp_sock?
> >>
> >>The notion of encap_type is needed for the setsockopt call so it wo=
uld
> >>have to stay in the API. If it were removed from udp_sock, getsocko=
pt
> >>would have to derive the encap_type from encap_rcv funcptr values, =
which
> >>would be messy. I think it might complicate the logic in ESP too.
> >=20
> >=20
> > Right. By the way, shouldn't "len" rather be signed in there?
> >=20
> > 		unsigned int len;
> >=20
> > 		/* if we're overly short, let UDP handle it */
> > 		len =3D skb->len - sizeof(struct udphdr);
> > 		if (len <=3D 0)
> > 			goto udp;
>=20
>=20
> It should, but the < 0 case can't happen since __udp4_lib_rcv
> already makes sure that we have at least a complete UDP header.
>=20
> Anyways, this patch fixes it.
>=20
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied, thanks.
