From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 1/2] [TCP]: Fix ratehalving with bidirectional
 flows
Date: Mon, 30 Jul 2007 22:21:12 -0700 (PDT)
Message-ID: <20070730.222112.41634340.davem@davemloft.net>
References: <Pine.LNX.4.64.0707302017290.8788@kivilampi-30.cs.helsinki.fi>
	<20070730.194946.08653937.davem@davemloft.net>
	<Pine.LNX.4.64.0707310751260.15079@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45716
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756284AbXGaFVL convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Jul 2007 01:21:11 -0400
In-Reply-To: <Pine.LNX.4.64.0707310751260.15079@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Tue, 31 Jul 2007 07:59:10 +0300 (EEST)

> I think it's probably good to add tp->snd_una !=3D prior_snd_una
> check there too... It's not going to make a large difference,
> mostly just to be conservative when skb collapse stuff got done
> (and maybe to annoy cheaters too though I couldn't at this point
> figure out how they could abuse it)...
>=20
> ...I think I can come up with that on Wednesday, so please hold
> stable push until that.

It'll definitely need to wait at least a day as I cannot even make TCP
or UDP connections out from my machine with the current net-2.6 tree,
and this is what I'm debugging at the moment.

I'm hoping that it's just something stupid like the make not
rebuilding everything necessary after I changed the __u16's into
__u32's in skb_frag_t.
