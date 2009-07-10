From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-2.6] Re: rib_trie / Fix inflate_threshold_root.
 Now=15 size=11 bits
Date: Fri, 10 Jul 2009 08:29:29 -0700
Message-ID: <20090710082929.31860886@nehalam>
References: <20090629083315.GA4712@ff.dom.local>
	<4A488EB8.4070602@itcare.pl>
	<20090629105820.GD4712@ff.dom.local>
	<20090630.124849.167332569.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jarkao2@gmail.com, pstaszewski@itcare.pl, robert@robur.slu.se,
	Robert.Olsson@data.slu.se, jorge@dti2.net, dada1@cosmosbay.com,
	robert.olsson@its.uu.se, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51226 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752032AbZGJP3f convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2009 11:29:35 -0400
In-Reply-To: <20090630.124849.167332569.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 30 Jun 2009 12:48:49 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Mon, 29 Jun 2009 10:58:20 +0000
>=20
> > On Mon, Jun 29, 2009 at 11:51:52AM +0200, Pawe=C5=82 Staszewski wro=
te:
> >> I apply this patch
> >>
> >> fib_triestats in attached file :)
> >>
> >>> ------------------->
> >>> ipv4: Fix fib_trie rebalancing, part 3
> >>>
> >>> Alas current delaying of freeing old tnodes by RCU in trie_rebala=
nce
> >>> is still not enough because we can free a top tnode before updati=
ng a
> >>> t->trie pointer.
> >>>
> >>> Reported-by: Pawel Staszewski <pstaszewski@itcare.pl>
> >>> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> >>> ---
> >=20
> > David, I guess you could add:
> >=20
> > Tested-by: Pawel Staszewski <pstaszewski@itcare.pl>
>=20
> Done, and applied, thanks Jarek.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

This is probably in kernel bugzilla as well, so someone should
update:
  http://bugzilla.kernel.org/show_bug.cgi?id=3D6648

--=20
