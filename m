From: Antonio Ospite <ospite@studenti.unina.it>
Subject: Re: [PATCH v4 2/2] Bluetooth: hidp: Add support for hidraw
 HIDIOCGFEATURE  and HIDIOCSFEATURE
Date: Fri, 24 Sep 2010 12:47:57 +0200
Message-ID: <20100924124757.fdbf702a.ospite@studenti.unina.it>
References: <1281442367.12579.206.camel@localhost.localdomain>
	<1281990059-3562-3-git-send-email-alan@signal11.us>
	<20100923115108.GC2379@null>
	<89BCFDE1-0D39-4248-84B2-E02C1480E067@signal11.us>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Fri__24_Sep_2010_12_47_57_+0200_3HcSCXOH2tD30cuO"
Cc: Ville Tervo <ville.tervo@nokia.com>, Jiri Kosina <jkosina@suse.cz>,
	Stefan Achatz <erazor_de@users.sourceforge.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Tejun Heo <tj@kernel.org>,
	Alan Stern <stern@rowland.harvard.edu>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Marcel Holtmann <marcel@holtmann.org>,
	Stephane Chatty <chatty@enac.fr>,
	Michael Poole <mdpoole@troilus.org>,
	"David S. Miller" <davem@davemloft.net>,
	Bastien Nocera <hadess@hadess.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"linux-input@vger.kernel.org" <linux-input@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"linux-bluetooth@vger.kernel.org" <linux-bluetooth@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alan Ott <alan@signal11.us>
Return-path: <linux-input-owner@vger.kernel.org>
In-Reply-To: <89BCFDE1-0D39-4248-84B2-E02C1480E067@signal11.us>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__24_Sep_2010_12_47_57_+0200_3HcSCXOH2tD30cuO
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, 23 Sep 2010 10:16:43 -0400
Alan Ott <alan@signal11.us> wrote:

>=20
> On Sep 23, 2010, at 7:51 AM, Ville Tervo wrote:
>=20
> > Hi Alan,
> >
> > One comment.
> >
> > How about a variable called ret and using that to return len or =20
> > errno? It
> > would eliminate code dublication.
> >
>=20
> Hi Ville,
>=20
> Where specifically? In which function? I've gone through it a couple =20
> of times and failed to find return statements which are superfluous. =20
> Maybe I'm missing something fundamental?
>=20

I guess he's referring to the return paths (normal, err_restartsys,
err_eio) in hidp_get_raw_report(), they could be merged into a
generic "out:" path by parametrizing the return value.

I don't know if Alan prefers explicit error paths, for me it's OK either
way.

Regards,
   Antonio

--=20
Antonio Ospite
http://ao2.it

PGP public key ID: 0x4553B001

A: Because it messes up the order in which people normally read text.
   See http://en.wikipedia.org/wiki/Posting_style
Q: Why is top-posting such a bad thing?

--Signature=_Fri__24_Sep_2010_12_47_57_+0200_3HcSCXOH2tD30cuO
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAkycgd0ACgkQ5xr2akVTsAF0HgCgrjChhONG+kYfvbfkgJjkQkks
Ek0AoJzjY7yPnFkZqDhB+oX0vNov4eYb
=0nuG
-----END PGP SIGNATURE-----

--Signature=_Fri__24_Sep_2010_12_47_57_+0200_3HcSCXOH2tD30cuO--
