From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH net-2.6 1/2] [TCP]: Fix ratehalving with bidirectional
 flows
Date: Tue, 31 Jul 2007 10:51:13 +0100
Message-ID: <20070731105113.4730d9bb@oldman.hamilton.local>
References: <Pine.LNX.4.64.0707302017290.8788@kivilampi-30.cs.helsinki.fi>
	<20070730.194946.08653937.davem@davemloft.net>
	<Pine.LNX.4.64.0707310751260.15079@kivilampi-30.cs.helsinki.fi>
	<20070730.222112.41634340.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:54156 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752631AbXGaJvj convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Jul 2007 05:51:39 -0400
In-Reply-To: <20070730.222112.41634340.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 30 Jul 2007 22:21:12 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: "Ilpo_J=C3=A4rvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Tue, 31 Jul 2007 07:59:10 +0300 (EEST)
>=20
> > I think it's probably good to add tp->snd_una !=3D prior_snd_una
> > check there too... It's not going to make a large difference,
> > mostly just to be conservative when skb collapse stuff got done
> > (and maybe to annoy cheaters too though I couldn't at this point
> > figure out how they could abuse it)...
> >=20
> > ...I think I can come up with that on Wednesday, so please hold
> > stable push until that.
>=20
> It'll definitely need to wait at least a day as I cannot even make TC=
P
> or UDP connections out from my machine with the current net-2.6 tree,
> and this is what I'm debugging at the moment.
>=20
> I'm hoping that it's just something stupid like the make not
> rebuilding everything necessary after I changed the __u16's into
> __u32's in skb_frag_t.

I running tests over emulator this morning.
Hopefully, this will fix the window collapse that occurs on startup
of large queue sizes.
