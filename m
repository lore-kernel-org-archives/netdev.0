From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [patch net-next v2 06/13] rocker: introduce worlds
 infrastructure
Date: Tue, 6 Oct 2015 20:42:51 +0000
Message-ID: <BBD86DDD-6EA2-482F-A8E0-9BECA7E4DF9D@intel.com>
References: <1444067046-27825-1-git-send-email-jiri@resnulli.us>
 <1444067046-27825-7-git-send-email-jiri@resnulli.us>
 <CAE4R7bA3dZ79U-Wg28m94=ZJBPRRQ2Xq=uM73ZrK5i2tNug=mg@mail.gmail.com>
 <20151006074355.GB2165@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_77AC93D9-F763-4CF5-B79C-BA68D2CC4108";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: Scott Feldman <sfeldma@gmail.com>, Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>,
	"eladr@mellanox.com" <eladr@mellanox.com>,
	Thomas Graf <tgraf@suug.ch>,
	Alexei Starovoitov <ast@plumgrid.com>,
	David Laight <David.Laight@aculab.com>,
	john fastabend <john.fastabend@gmail.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:40865 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752432AbbJFUm5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Oct 2015 16:42:57 -0400
In-Reply-To: <20151006074355.GB2165@nanopsycho.orion>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_77AC93D9-F763-4CF5-B79C-BA68D2CC4108
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

Jiri Pirko <jiri@resnulli.us> wrote:

>>> +       int (*port_init)(struct rocker_port *rocker_port, void =
*priv,
>>> +                        void *port_priv);
>>=20
>> Yuck, void *.  Can we do better?
>=20
> I see nothing wrong with this priv usage. It's done like this on many
> places. I think it is completely legit, since the call points are well
> defined and wrapped.

This particular call is perhaps the most troubling. In general, if there =
is one void parameter you may well get a compile error on a non-void =
parameter if you get them switched around. With two void parameters that =
is no longer the case, making it even more error-prone than the other =
uses of void *.

--
Mark Rustad, Networking Division, Intel Corporation

--Apple-Mail=_77AC93D9-F763-4CF5-B79C-BA68D2CC4108
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCAAGBQJWFDJLAAoJEDwO/+eO4+5uu34P/2+JpMxhHF7HUxhrGCJuM0tZ
2FXq1OT7zKcTuNksgpisqm9tYzButAc7TH2Kn++wPRt9H5Ko9xkFA6MSzZLGhkRd
QK1VvDOWam69ZHmyyAaVmJK2G7QzidfIzOUfjCHO/xir2o4y/b4FKXrGi78agG31
aeh4MCzY/WHvLJpljBnmNtaGC7qVc4Go2ePrFXkSEz5hnojFrF1Acu68RqFEP1ho
Jbr26XpKPRA6Ghh4hnZxxqMW1tAJFPIFyjRgEjyy7cWZ/5TWbGJU8rUA7Q/7wQE/
OmlEIWcGPafdEFYCp5XDo1ITZOQXirocZjQLyqWJrbEJm0z5bI5tV8v3sNvrcW/E
FEoX9OJpCl5PVOP/LlvHTR3OVKoze82MzUW1bHoNO3jtv5sGvzaWA1dx/oInY7Sp
hXCLp/0943o7PIMjPldLUJZwthqsRDvya99YwppzNK1pSl7aJuYQTDc7k+Z4LW6B
W5w8ygAHr2CUbHp0ZcOrRDKgLZ2BfGOACHfFm/wkOUEs8wx9fhiuuBslLGqEGu+u
4e/t8/5CMB6QvBmQW/eoTGvfXu7HjGEU21F1PeSmmQt2I3rKBDye5IvxCCSouWyo
Em/Xx16bTS0kjQfdSjSlYcIEHg+BJGVP1fXQzY6bgvqKgGeTBOszacKHC1qW8qE1
WDjBsc0f+vABmdjDSw7n
=d5BI
-----END PGP SIGNATURE-----

--Apple-Mail=_77AC93D9-F763-4CF5-B79C-BA68D2CC4108--
