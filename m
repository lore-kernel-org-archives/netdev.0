From: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Subject: Re: [PATCH net-next v2 00/12] cdc_ncm: add buffer tuning and stats
 using ethtool
Date: Sun, 08 Jun 2014 23:02:02 +0100
Message-ID: <1402264922.23860.37.camel@deadeye.wl.decadent.org.uk>
References: <1400269709-18854-1-git-send-email-bjorn@mork.no>
	 <20140516.224032.2301577488192248796.davem@davemloft.net>
	 <87d2fcoqay.fsf@nemi.mork.no> <20140518011917.11270.qmail@stuge.se>
	 <alpine.LNX.2.03.1405181155310.7743@gmail.com>
	 <87vbt3m98p.fsf@nemi.mork.no> <5378E985.1040206@gmail.com>
	 <87egzqmd8h.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-cThyY+frzCEftZRVE+iA"
Cc: Lars Melin <larsm17-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Peter Stuge <peter-Y+HMSxxDrH8@public.gmane.org>,
	Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org, David.Laight-JxhZ9S5GRejQT0dZR+AlfA@public.gmane.org
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87egzqmd8h.fsf-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-cThyY+frzCEftZRVE+iA
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-05-19 at 09:36 +0200, Bj=C3=B8rn Mork wrote:
> Lars Melin <larsm17-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
>=20
> > Your target audience is embedded systems with limited cpu power and
> > buffer memory, right?
> > If so, then you can't expect them to have ethtool included and their
> > developers are not likely to be happy over having to "waste" another
> > 100KB in order to tune a 20KB driver.
> > My vote goes for sysfs.
>=20
> That's of course a very good point.
>=20
> I will argue that you often need ethtool anyway for basic stuff like
> forcing duplex/speed, enabling debug messages, turning on/off pause
> frames etc.  But I don't doubt you know what you are talking about here
> :-)  So I guess many small embedded devices don't include an ethtool
> binary by default.  I do wonder how much we should adapt to that though?
> I understand that you don't see it this way, but others might actually
> see it as an advantage if we're forcing ethtool onto these devices...
[...]

By the way, ethtool can now be configured without pretty-printing of
register/EEPROM dumps.  This reduces it in size from ~240K to ~60K.

If that's still not small enough, the answer might be to put a limited
reimplementation of ethtool in busybox, toybox or similar.

Ben.

--=20
Ben Hutchings
Never attribute to conspiracy what can adequately be explained by stupidity=
.

--=-cThyY+frzCEftZRVE+iA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUAU5TdX+e/yOyVhhEJAQrmog/+I7/ASfsEuk8XkRuxdWXITfCbPZ9zI2hC
9uSmHZb1gHX4HJh7JRY7a0D6h++a7HvdK/85grZ1O5+OFDVJUt8KV7fdZfDVGZY/
rUN35lmfVP0MzHZ7tZuYhmj+8pAUPxuTWfptB904Qd+W2kbKdcprhRjnG1etlGr1
u2BW0R+ix1snELKqRXWY+/DJk0Dc0s8k5VOI4le6rlpB+TeL945waDcSe2pUbi95
/WG+DLc6WkTX3HT1AZgNgCptlp021RwEFROuSj5Ytqoqyb6rRqut+1rxhD2PXCBP
V2k1TfRbsZQBtPFANPGLzy8n/5f5/fmfpYN8kUdUgfbQ0lHdXmky/aWt+VE0MdX7
82sHQ4zZNFlLx1gKcyQztNq4dR6oZcB2hckHJSeUuwpHD/1ga1z5MMs4kjDXqb78
2z27WKaYLKN1vNF89Zurbjbv8GOA7mt7pfoOjsqPf7X9pYhm4fjwEBLAJqrYq9Xg
8B9cDUB/IRgKyhv6o4Pv/noLO6Cboa1rsdvOh/41Wd67BpuhSx3D3xZgJh9JpJnt
dBFsSvef/HzLrJZ/RjNImYpdZQ2Frw9ikRo4TuOdpr9pkfL5PGUC0K2FshAJtj+a
lkdXWVWoj2VWvA4x5l68lMZKQAveeQUOiWJaCVRJMrGdrXQ2PXhEHodhJoUCBH8k
oXiWFQ2ujDE=
=i/YC
-----END PGP SIGNATURE-----

--=-cThyY+frzCEftZRVE+iA--
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
