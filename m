From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net-next tree
Date: Mon, 19 Jan 2015 14:06:10 +1100
Message-ID: <20150119140610.6b41b5ef@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/f+KABpqlzq61FD8th6Oe4hx"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jiri Pirko <jiri@resnulli.us>,
	Scott Feldman <sfeldma@gmail.com>,
	Gustavo Padovan <gustavo@padovan.org>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/f+KABpqlzq61FD8th6Oe4hx
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net-next tree, today's linux-next build (powerpc
ppc64_defconfig) failed like this:

In file included from net/bridge/br.c:22:0:
include/net/switchdev.h:73:1: error: expected identifier or '(' before '{' =
token
 {
 ^
include/net/switchdev.h:71:19: warning: 'call_netdev_switch_notifiers' decl=
ared 'static' but never defined [-Wunused-function]
 static inline int call_netdev_switch_notifiers(unsigned long val, struct n=
et_device *dev,
                   ^

Caused by commit 03bf0c281234 ("switchdev: introduce switchdev notifier").

I have used the net-next tree from next-20150116 for today.  I also had
to use the bluetooth tree from next-20150116 as it was fast forwarded
to be the same as the net-next tree today.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/f+KABpqlzq61FD8th6Oe4hx
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJUvHSnAAoJEMDTa8Ir7ZwVC9EP/16734XQidexho/rbTWlTbrB
VrRJx9cNyGPCvVSi6Gev1jf3ctfis6vPskyOTnfy6F4cWDCsrbuBck1qxH7DhtHX
Jvl4/Uko9R/A7XSCdGLw6Bv7pDUuvyG7Twz8seuoogLJON/K4k3Plpi79rgsIgNn
o3Q5qwY/fZJwH3FJBElytoszKJK3/zdKrdGnlmotT5lNag0VMdb+hwiY57T245Pk
ido3H+J1xyNM/YphrLCy+iqreDHbJOIxBROnvSBip1As93oZWHmJEayOy6OQLPUn
jQRjBSSylgOuEAO/mv4w6kN9eEURR11nnWo5HGySyoV7vMiTZ7tPxPhoAWf4fpZP
p3IPw0Rh2dTiRIzam+FKxatT1xNPsWtxbk8SefwTxOcwNtafaOeWwcVmFvhdkHM4
wPGYeZsW0/F5yNX1jPMWseD3VuN2b/6yfWmLhEUgjv2ONyhAO+omBoK3HIyigkuv
81C176fwVHIJg5qN/M1d18TwUCvQWIHFVeSyVaHsHveGVWxe2oSec4JMyHQjxWvG
AanCSoSvyU1WYAMm8CebWKZUcrDkSg8rRzinSz+9oCjDg140qXKxevGh+/Mm9W7u
qjH1x/dhhKmbcae18/KY+NXgZOSJJw4wafiMyMOrxkT4agNIYdubreUWo7+lbgeT
bVM07I4CBfWStlitRrvX
=jr+B
-----END PGP SIGNATURE-----

--Sig_/f+KABpqlzq61FD8th6Oe4hx--
