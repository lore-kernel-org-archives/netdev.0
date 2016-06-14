From: Henrik Austad <henrik@austad.us>
Subject: Re: [very-RFC 0/8] TSN driver for the kernel
Date: Tue, 14 Jun 2016 22:38:10 +0200
Message-ID: <20160614203810.GC21689@sisyphus.home.austad.us>
References: <1465686096-22156-1-git-send-email-henrik@austad.us>
 <20160613114713.GA9544@localhost.localdomain>
 <20160613130059.GA20320@sisyphus.home.austad.us>
 <20160613193208.GA2441@netboy>
 <20160614093000.GB21689@sisyphus.home.austad.us>
 <20160614182615.GA2741@netboy>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ZwgA9U+XZDXt4+m+"
Cc: linux-kernel@vger.kernel.org, linux-media@vger.kernel.org,
	alsa-devel@vger.kernel.org, netdev@vger.kernel.org,
	Arnd Bergmann <arnd@linaro.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160614182615.GA2741@netboy>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--ZwgA9U+XZDXt4+m+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jun 14, 2016 at 08:26:15PM +0200, Richard Cochran wrote:
> On Tue, Jun 14, 2016 at 11:30:00AM +0200, Henrik Austad wrote:
> > So loop data from kernel -> userspace -> kernelspace and finally back t=
o=20
> > userspace and the media application?
>=20
> Huh?  I wonder where you got that idea.  Let me show an example of
> what I mean.
>=20
> 	void listener()
> 	{
> 		int in =3D socket();
> 		int out =3D open("/dev/dsp");
> 		char buf[];
>=20
> 		while (1) {
> 			recv(in, buf, packetsize);
> 			write(out, buf + offset, datasize);
> 		}
> 	}
>=20
> See?

Where is your media-application in this? You only loop the audio from=20
network to the dsp, is the media-application attached to the dsp-device?

Whereas I want to do=20

aplay some_song.wav
or mplayer
or spotify
or ..


> > Yes, I know some audio apps "use networking", I can stream netradio, I =
can=20
> > use jack to connect devices using RTP and probably a whole lot of other=
=20
> > applications do similar things. However, AVB is more about using the=20
> > network as a virtual sound-card.
>=20
> That is news to me.  I don't recall ever having seen AVB described
> like that before.
>=20
> > For the media application, it should not=20
> > have to care if the device it is using is a soudncard inside the box or=
 a=20
> > set of AVB-capable speakers somewhere on the network.
>=20
> So you would like a remote listener to appear in the system as a local
> PCM audio sink?  And a remote talker would be like a local media URL?
> Sounds unworkable to me, but even if you were to implement it, the
> logic would surely belong in alsa-lib and not in the kernel.  Behind
> the enulated device, the library would run a loop like the example,
> above.
>=20
> In any case, your patches don't implement that sort of thing at all,
> do they?

Subject: [very-RFC 7/8] AVB ALSA - Add ALSA shim for TSN

Did you even bother to look?

--=20
Henrik Austad

--ZwgA9U+XZDXt4+m+
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAldgazIACgkQ6k5VT6v45lkBYACePNiLE3TpU9VONnqHAbNfEtBA
HzIAn3AGu7lakjCHeutRZ7Yn2fDegbSV
=QsdK
-----END PGP SIGNATURE-----

--ZwgA9U+XZDXt4+m+--
