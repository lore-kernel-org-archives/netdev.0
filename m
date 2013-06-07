From: Matthias Schiffer <mschiffer@universe-factory.net>
Subject: Re: [PATCH net/3.9] ipv6: ndisc: fix ndisc_send_redirect writing
 to the wrong skb
Date: Fri, 07 Jun 2013 13:00:52 +0200
Message-ID: <51B1BD64.8090300@universe-factory.net>
References: <51A66CF3.7010202@universe-factory.net> <5578958b49fff222740711e091c2325100f5a440.1369963643.git.mschiffer@universe-factory.net> <CAM_iQpWNAnRTgzjPTPxLU-eqz1nWqD=zyjTgwZaaxbwcpf4KMw@mail.gmail.com> <20130531.014244.1871655049070137342.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="----enig2MFPEVCVABNCPCGVIDOJI"
Cc: xiyou.wangcong@gmail.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130531.014244.1871655049070137342.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
------enig2MFPEVCVABNCPCGVIDOJI
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 05/31/2013 10:42 AM, David Miller wrote:
> From: Cong Wang <xiyou.wangcong@gmail.com>
> Date: Fri, 31 May 2013 11:23:11 +0800
>=20
>> On Fri, May 31, 2013 at 9:27 AM, Matthias Schiffer
>> <mschiffer@universe-factory.net> wrote:
>>> Since some refactoring in 5f5a011, ndisc_send_redirect called
>>> ndisc_fill_redirect_hdr_option on the wrong skb, leading to data corr=
uption or
>>> in the worst case a panic when the skb_put failed.
>>>
>>> Signed-off-by: Matthias Schiffer <mschiffer@universe-factory.net>
>>
>>
>> Good catch!
>>
>> Reviewed-by: Cong Wang <xiyou.wangcong@gmail.com>
>=20
> I've queued this up for -stable.
>=20

I saw that this was marked as 'not applicable' in the patchwork - it
should still be applied to the net tree though. I hope my patch tag
'net/3.9' didn't cause any confusion, I meant net *and* 3.9.


------enig2MFPEVCVABNCPCGVIDOJI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlGxvWQACgkQq3qIxbiQM9jQDQCeOhCY5fZEloQgamjoNpkEh2L5
tdkAn1Wk+/FLQBrDZ4wrVzPnieLb/LZ8
=Eii2
-----END PGP SIGNATURE-----

------enig2MFPEVCVABNCPCGVIDOJI--
