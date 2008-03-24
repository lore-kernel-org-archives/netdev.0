From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] [TCP]: Must count fack_count also when skipping
Date: Mon, 24 Mar 2008 14:41:07 -0700 (PDT)
Message-ID: <20080324.144107.235200795.davem@davemloft.net>
References: <Pine.LNX.4.64.0803031525390.27064@kivilampi-30.cs.helsinki.fi>
	<Pine.LNX.4.64.0803031541230.28251@kivilampi-30.cs.helsinki.fi>
	<pan.2008.03.24.20.36.07@telenet.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: fhimpe@telenet.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46700
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752437AbYCXVlI convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Mar 2008 17:41:08 -0400
In-Reply-To: <pan.2008.03.24.20.36.07@telenet.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Frederik Himpe <fhimpe@telenet.be>
Date: Mon, 24 Mar 2008 20:36:08 +0000 (UTC)

> On Mon, 03 Mar 2008 15:53:12 +0200, Ilpo J=E4rvinen
> wrote:
>=20
> > [PATCH net-2.6] [TCP]: Must count fack_count also when skipping
> >=20
> > It makes fackets_out to grow too slowly compared with the real writ=
e
> > queue.
> >=20
> > This shouldn't cause those BUG_TRAP(packets <=3D tp->packets_out) t=
o
> > trigger but how knows how such inconsistent fackets_out affects her=
e and
> > there around TCP when everything is nowadays assuming accurate
> > fackets_out. So lets see if this silences them all.
> >=20
> > Reported by Guillaume Chazarain <guichaz@gmail.com>.
>=20
> Will this patch be applied to 2.6.24 stable? I think I have been hit =
by=20
> the same problem recently:

I'll push it to the -stable folks for their next release
since people are actively hitting it.
