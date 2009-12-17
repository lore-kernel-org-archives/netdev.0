From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] Libertas: fix buffer overflow in lbs_get_essid()
Date: Wed, 16 Dec 2009 20:01:15 -0500
Message-ID: <20091217010114.GA2913@tuxdriver.com>
References: <1260936778-2096-1-git-send-email-daniel@caiaq.de>
 <1260982667.2179.9.camel@localhost.localdomain>
 <20091216231508.GX28375@buzzloop.caiaq.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dan Williams <dcbw@redhat.com>, linux-kernel@vger.kernel.org,
	Holger Schurig <holgerschurig@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Maithili Hinge <maithili@marvell.com>,
	Kiran Divekar <dkiran@marvell.com>,
	Michael Hirsch <m.hirsch@raumfeld.com>, netdev@vger.kernel.org,
	libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
	stable@kernel.org
To: Daniel Mack <daniel@caiaq.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:41621 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762760AbZLQBGX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2009 20:06:23 -0500
Content-Disposition: inline
In-Reply-To: <20091216231508.GX28375@buzzloop.caiaq.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 17, 2009 at 07:15:08AM +0800, Daniel Mack wrote:
> On Wed, Dec 16, 2009 at 08:57:47AM -0800, Dan Williams wrote:
> > On Wed, 2009-12-16 at 05:12 +0100, Daniel Mack wrote:
> > > The libertas driver copies the SSID buffer back to the wireless c=
ore and
> > > appends a trailing NULL character for termination. This is
> > >=20
> > > a) unnecessary because the buffer is allocated with kzalloc and i=
s hence
> > >    already NULLed when this function is called, and
> > >=20
> > > b) for priv->curbssparams.ssid_len =3D=3D 32, it writes back one =
byte too
> > >    much which causes memory corruptions.
> > >=20
> > > Fix this by removing the extra write.
> >=20
> > Acked-by: Dan Williams <dcbw@redhat.com>
>=20
> Thanks, everyone. Who will care to pick an queue this one?

Is there some reason it wouldn't be me?

John
--=20
John W. Linville =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Someday the world will =
need a hero, and you
linville@tuxdriver.com =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0might be all =
we have. =A0Be ready.
