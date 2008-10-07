From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 net-next] tcp: kill pointless urg_mode
Date: Tue, 07 Oct 2008 14:42:48 -0700 (PDT)
Message-ID: <20081007.144248.48552653.davem@davemloft.net>
References: <Pine.LNX.4.64.0810032328550.30507@wrl-59.cs.helsinki.fi>
	<Pine.LNX.4.64.0810040050540.30997@wrl-59.cs.helsinki.fi>
	<Pine.LNX.4.64.0810041505340.697@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34646
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754761AbYJGVnM convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Oct 2008 17:43:12 -0400
In-Reply-To: <Pine.LNX.4.64.0810041505340.697@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sat, 4 Oct 2008 15:08:19 +0300 (EEST)

> On Sat, 4 Oct 2008, Ilpo J=E4rvinen wrote:
>=20
> > On Fri, 3 Oct 2008, Ilpo J=E4rvinen wrote:
> >=20
> > > On Fri, 3 Oct 2008, Ilpo J=E4rvinen wrote:
> > >=20
> > > > It all started from me noticing that this urgent check in
> > > > tcp_clean_rtx_queue is unnecessarily inside the loop. Then
> > > > I took a longer look to it and found out that the users of
> > > > urg_mode can trivially do without. Just drag snd_up with
> > > > us when we advance.
> > >=20
> > > Please hold a minute with this one while I inspect why I saw
> > > some strange urg now in a tcpdump.
> >=20
> > Ok, now it's right with win probes too...
> >
> > --
> >=20
> > [PATCHv2 net-next] tcp: kill pointless urg_mode
>=20
> Even better this time... tcp_urg_mode moved to tcp_output.c and excha=
nged
> the tcp_transmit_skb checks to the original order.
>=20
> --
> [PATCHv3 net-next] tcp: kill pointless urg_mode

Oops, I'll apply this one instead, of course :)
