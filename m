From: Frederic Leroy <fredo@starox.org>
Subject: Re: scp stalls mysteriously
Date: Mon, 30 Nov 2009 22:24:17 +0100
Message-ID: <20091130222417.77ce13a4@houba>
References: <20091127223545.2a752429@houba>
	<alpine.DEB.2.00.0911272358030.11977@melkinpaasi.cs.helsinki.fi>
	<20091128010156.1219012a@houba>
	<alpine.DEB.2.00.0911281257270.25587@melkinpaasi.cs.helsinki.fi>
	<20091130195004.38dbc319@houba>
	<alpine.DEB.2.00.0911302113390.9826@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>, Asdo <asdo@shiftmail.org>
To: "Ilpo =?UTF-8?B?SsOkcnZpbmVu?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sd-11162.dedibox.fr ([88.191.70.230]:47820 "EHLO
	sd-11162.dedibox.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753285AbZK3VYc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 16:24:32 -0500
In-Reply-To: <alpine.DEB.2.00.0911302113390.9826@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Mon, 30 Nov 2009 22:18:22 +0200 (EET),
"Ilpo J=C3=A4rvinen" <ilpo.jarvinen@helsinki.fi> a =C3=A9crit :

> On Mon, 30 Nov 2009, Frederic Leroy wrote:
>=20
> > Le Sat, 28 Nov 2009 13:31:14 +0200 (EET),
> > "Ilpo J=C3=A4rvinen" <ilpo.jarvinen@helsinki.fi> a =C3=A9crit :
> point out to yet another problem, however, I'm not sure what I can
> atm trust in the logs. ...Timestamps would probably help me a bit
> (I've changed also sleep to do 0.01 granularity):

I made 2 other traces with 0.01 granularity, but it works normally. I
suppose there are less interference in the evening.

The .4 is a bad trace where I forgot to put timestamp. And when I
realized it was copying successfully, I stopped it before it tooks too
much space.

It can be interesting because the stream had a little "pause".

The .5 is the trace of a successfull copy. I limited packet capture siz=
e
to 96 bytes. It has stalled once in the middle.

--=20
=46r=C3=A9d=C3=A9ric Leroy
