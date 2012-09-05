From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: sctp_close/sk_free: kernel BUG at arch/x86/mm/physaddr.c:18!
Date: Wed, 05 Sep 2012 17:01:05 +0200
Message-ID: <50476931.20100@pengutronix.de>
References: <20120904140411.GB15068@localhost> <5046361C.5070602@pengutronix.de> <87mx15zfze.fsf@xmission.com> <20120905145508.GA9450@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigD70E997047BA2043243B476E"
Cc: "H.K. Jerry Chu" <hkchu@google.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	networking <netdev@vger.kernel.org>, linux-can@vger.kernel.org
To: Fengguang Wu <fengguang.wu@intel.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20120905145508.GA9450@localhost>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigD70E997047BA2043243B476E
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 09/05/2012 04:55 PM, Fengguang Wu wrote:
>>> This in turn means the problem doesn't come from the CAN patches, as
>>> both trees have different CAN patches. I'm adding Eric W. Biederman o=
n
>>> Cc as he contributed some sctp patches between v3.6 and net-next/mast=
er.
>>
>> Anything is possible, but this seems unlikely as I don't think I touch=
ed
>> anything close to that part of the code.
>=20
> You are both right.  The bad commit turns out to be one of:
>=20
> 1bed966cc3bd4042110129f0fc51aeeb59c5b200 Merge branch 'tcp_fastopen_ser=
ver'
> 168a8f58059a22feb9e9a2dcc1b8053dbbbc12ef tcp: TCP Fast Open Server - ma=
in code path
> 8336886f786fdacbc19b719c1f7ea91eb70706d4 tcp: TCP Fast Open Server - su=
pport TFO listeners
>=20
> Thanks,
> Fengguang

Thanks for your work Fengguang.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigD70E997047BA2043243B476E
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://www.enigmail.net/

iEYEARECAAYFAlBHaTcACgkQjTAFq1RaXHOIyACbBPcV5K/H9YW1mbjzf8XCsiWG
8bQAn1UDyyZ2iW8k47+xjoXNxoX7njcZ
=N4jZ
-----END PGP SIGNATURE-----

--------------enigD70E997047BA2043243B476E--
