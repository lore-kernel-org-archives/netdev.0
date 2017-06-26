From: Matthias Schiffer <mschiffer@universe-factory.net>
Subject: Re: [PATCH net-next v2 4/5] net: add netlink_ext_ack argument to
 rtnl_link_ops.slave_changelink
Date: Mon, 26 Jun 2017 15:45:31 +0200
Message-ID: <bb1892a4-2227-cdc4-e017-f39f133fd20a@universe-factory.net>
References: <cover.1498425679.git.mschiffer@universe-factory.net>
 <498ff06f59d5ce13b2ad3e1c1902c3d348ca3c00.1498425679.git.mschiffer@universe-factory.net>
 <b097a69e-4449-b124-c39e-4dbdbae7c218@gmail.com>
 <dd3f596b-4519-398c-a2ec-afdaf5f2f058@gmail.com>
 <15d2138d-5026-a35b-8a3c-2a88d05df688@universe-factory.net>
 <27b8d607-7442-0a42-1389-9548840445dc@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="GTa8fbVwFBKQGGC8RgHH4pbDJVT0tmtkl"
Cc: linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, linux-can@vger.kernel.org,
        linux-ppp@vger.kernel.org, linux-wpan@vger.kernel.org
To: David Ahern <dsahern@gmail.com>, dledford@redhat.com,
        sean.hefty@intel.com, hal.rosenstock@gmail.com,
        j.vosburgh@gmail.com, vfalico@gmail.com, andy@greyhouse.net,
        wg@grandegger.com, mkl@pengutronix.de, pablo@netfilter.org,
        laforge@gnumonks.org, paulus@samba.org, jiri@resnulli.us,
        dsa@cumulusnetworks.com, shm@cumulusnetworks.com,
        davem@davemloft.net, stephen@networkplumber.org,
        arvid.brodin@alten.se, alex.aring@gmail.com,
        stefan@osg.samsung.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net,
        steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
        johannes@sipsolutions.net
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <27b8d607-7442-0a42-1389-9548840445dc@gmail.com>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--GTa8fbVwFBKQGGC8RgHH4pbDJVT0tmtkl
Content-Type: multipart/mixed; boundary="79eUx2TbmCT9D35527FaXM5RNxUbpWIhc";
 protected-headers="v1"
From: Matthias Schiffer <mschiffer@universe-factory.net>
To: David Ahern <dsahern@gmail.com>, dledford@redhat.com,
 sean.hefty@intel.com, hal.rosenstock@gmail.com, j.vosburgh@gmail.com,
 vfalico@gmail.com, andy@greyhouse.net, wg@grandegger.com,
 mkl@pengutronix.de, pablo@netfilter.org, laforge@gnumonks.org,
 paulus@samba.org, jiri@resnulli.us, dsa@cumulusnetworks.com,
 shm@cumulusnetworks.com, davem@davemloft.net, stephen@networkplumber.org,
 arvid.brodin@alten.se, alex.aring@gmail.com, stefan@osg.samsung.com,
 kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
 kaber@trash.net, steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
 johannes@sipsolutions.net
Cc: linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
 netdev@vger.kernel.org, linux-can@vger.kernel.org,
 linux-ppp@vger.kernel.org, linux-wpan@vger.kernel.org
Message-ID: <bb1892a4-2227-cdc4-e017-f39f133fd20a@universe-factory.net>
Subject: Re: [PATCH net-next v2 4/5] net: add netlink_ext_ack argument to
 rtnl_link_ops.slave_changelink
References: <cover.1498425679.git.mschiffer@universe-factory.net>
 <498ff06f59d5ce13b2ad3e1c1902c3d348ca3c00.1498425679.git.mschiffer@universe-factory.net>
 <b097a69e-4449-b124-c39e-4dbdbae7c218@gmail.com>
 <dd3f596b-4519-398c-a2ec-afdaf5f2f058@gmail.com>
 <15d2138d-5026-a35b-8a3c-2a88d05df688@universe-factory.net>
 <27b8d607-7442-0a42-1389-9548840445dc@gmail.com>
In-Reply-To: <27b8d607-7442-0a42-1389-9548840445dc@gmail.com>

--79eUx2TbmCT9D35527FaXM5RNxUbpWIhc
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable

On 06/26/2017 03:33 PM, David Ahern wrote:
> On 6/26/17 2:43 AM, Matthias Schiffer wrote:
>> On 06/26/2017 06:08 AM, David Ahern wrote:
>>> On 6/25/17 10:04 PM, David Ahern wrote:
>>>> On 6/25/17 3:56 PM, Matthias Schiffer wrote:
>>>>> Add support for extended error reporting.
>>>>>
>>>>> Signed-off-by: Matthias Schiffer <mschiffer@universe-factory.net>
>>>>> ---
>>>>
>>>>
>>>> Acked-by: David Ahern <dsahern@gmail.com>
>>>>
>>>
>>> Actually, you are missing the chagne to br_port_slave_changelink.
>>>
>>
>> I'm confused. I am changing br_port_slave_changelink? All my patches a=
re
>> compile-tested.
>>
>=20
> You are changing the signature of slave_changelink, no?
>=20
> net/bridge/br_netlink.c:
>         .slave_changelink       =3D br_port_slave_changelink,
>=20


Please read my patch again, I *am* changing br_port_slave_changelink to
match the new signature (this is the net/bridge/br_netlink.c change
appearing in the diffstat).


--79eUx2TbmCT9D35527FaXM5RNxUbpWIhc--

--GTa8fbVwFBKQGGC8RgHH4pbDJVT0tmtkl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCgAdFiEEZmTnvaa2aYgexS51Fu8/ZMsgHZwFAllRD/sACgkQFu8/ZMsg
HZytlBAAoMVDlNFcYxYailktFYE6emS4PpNrH1sTCFONTOxx0iX6w6ARjBUQSf3M
8E7oJKOZhS+kAFS0/pzAtxsuSRyNAM/LF0NUoCbyj1ib9uETz8adwEcgYjj8WbMc
BxaRKloCTYev2GXQ7ZLUkm8ebcE08N6MJEcmasgD2xg7dxDNypSt3wOzf9K+OBBM
QcUi3a9g2VKzmycMZFUc1hBDMkrmOqUQoRro/I50WE5/Pd4c9636kx/uEPXkox3m
dsbavWCHleeZ6BDcMSplOGUMr4UtfdyNhBpjX6eMllb60XyTRAAf3N4CFG/Ygua/
O3Y1C313cRyqXFC4eTcZGGktOVDfn48gDqKOSNh/uqTHn/yk/rECjEfdKyA2cgzD
lk3vCef1OSAKEzsflpqB5r07q7yCpG5COQQl810DxRM3aswZfx/PlA2iZEWzZ/3/
iFb3l/Yr1nFUkgmGD9RUSTKVfhwiog9UQFY+CUkdM1pPEahdMSj6dNOeMHEjkCSr
xP8iAWBOHaLqRnnIKW++RbBPuqP/ktiuOcp04tVQORsuzvdB6TH+IoLcrCfRgaxF
U2DokX5TFwstv7Ph4sd7KCm9NbByfLnsXfSY1O5LLzroboEfrrnqsImz4KurOSKQ
JKwuQBS835eifu8sxf59z1xJFMndYLJ5fCbKftQlWLNHn363WW0=
=CwTz
-----END PGP SIGNATURE-----

--GTa8fbVwFBKQGGC8RgHH4pbDJVT0tmtkl--
