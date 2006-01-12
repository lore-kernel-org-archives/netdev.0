From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [Bcm43xx-dev] [Fwd: State of the Union: Wireless]
Date: Thu, 12 Jan 2006 15:20:42 +0100
Message-ID: <20060112142042.GJ4430@sunbeam.de.gnumonks.org>
References: <1136541243.4037.18.camel@localhost> <200601061200.59376.mbuesch@freenet.de> <1136547494.7429.72.camel@localhost> <200601061245.55978.mbuesch@freenet.de> <1136549423.7429.88.camel@localhost> <43BE6697.3030009@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="FFpMipsYUdYbs4p3"
Cc: Marcel Holtmann <marcel@holtmann.org>,
	Michael Buesch <mbuesch@freenet.de>, jgarzik@pobox.com,
	bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030416AbWALOUs@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <43BE6697.3030009@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--FFpMipsYUdYbs4p3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Jan 06, 2006 at 01:46:15PM +0100, Patrick McHardy wrote:
> Marcel Holtmann wrote:
>=20
> >>I just personally liked the idea of having a device node in /dev for
> >>every existing hardware wlan card. Like we have device nodes for
> >>other real hardware, too. It felt like a bit of a "unix way" to do
> >>this to me. I don't say this is the way to go.
> >>If a netlink socket is used (which is possible, for sure), we stay with
> >>the old way of having no device node in /dev for networking devices.
> >>That is ok. But that is really only an implementation detail (and for s=
ure
> >>a matter of taste).
> >At the OLS last year, I think the consensus was to use netlink for all
> >configuration task. However this was mainly driven by Harald Welte and
> >he might be able to talk about the pros and cons of netlink versus a
> >character device.
>=20
> I think the main advantages of netlink over a character device is its
> flexible format, which is easily extendable, and multicast capability,

Especially the multicast capability is _extrmely_ handy, since you
basically can have all sorts of dock-applets or monitoring applications
that don't need to rely on polling device status but instead get
multicast notifications of configuration changes.

Also, as a theoretical option, you could implement parts of the wireless
subsystem outside of the kernel - esp. for the more extensive
authentication/keying/rekeying functions.

A wireless configuration program would just speak netlink to a
particular netlink multicast group.  Whether or not the receiving
functional entity is implemented in the kernel or in a wireless daemon
in userspace could be completely transparent, as long as the protocol is
the same.

--=20
- Harald Welte <laforge@gnumonks.org>          	        http://gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)

--FFpMipsYUdYbs4p3
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQFDxmW6XaXGVTD0i/8RAtBvAJwKF7nZr5hGEJh5wykwtmZLMFUbGwCcCttg
DEByg/xBH9UAbg0Ra/tDjWw=
=zQ0E
-----END PGP SIGNATURE-----

--FFpMipsYUdYbs4p3--
