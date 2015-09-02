From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [net-next 05/19] ixgbe: Add support for UDP-encapsulated tx
 checksum offload
Date: Wed, 2 Sep 2015 16:46:42 +0000
Message-ID: <F63CFE64-29E1-484B-B19B-269FAAA9C54B@intel.com>
References: <1441156443-33381-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1441156443-33381-6-git-send-email-jeffrey.t.kirsher@intel.com>
 <CALx6S34-mUvQyUQNcVC+o+NeUxWEsCG2GS=Eq++eGqoh=kv8kg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_90A5B14F-3215-4C6F-8AC6-9F1C0EC7373A";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:34407 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755106AbbIBQqq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Sep 2015 12:46:46 -0400
In-Reply-To: <CALx6S34-mUvQyUQNcVC+o+NeUxWEsCG2GS=Eq++eGqoh=kv8kg@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_90A5B14F-3215-4C6F-8AC6-9F1C0EC7373A
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

> On Sep 1, 2015, at 8:17 PM, Tom Herbert <tom@herbertland.com> wrote:
>=20
> I suspect this is not UDP-encapsulation specific, will it work with
> TCP/IP/IP, TCP/IP/GRE etc.?

It could do more, but this is what has been tested up to this point.

> Isn't there anyway the ixgbe could just be made to NETIF_HW_CSUM? That
> would be so much more straightforward and support nearly all use cases
> without needing to jump through all these hoops.

Well, the description says:

 ---
Note: NETIF_F_HW_CSUM is a superset of NETIF_F_IP_CSUM + =
NETIF_F_IPV6_CSUM.
It means that device can fill TCP/UDP-like checksum anywhere in the =
packets
whatever headers there might be.
 ---

The device can't do whatever, wherever. There is always a limit to the =
offset to the inner headers that can be handled, for instance.

--
Mark Rustad, Networking Division, Intel Corporation


--Apple-Mail=_90A5B14F-3215-4C6F-8AC6-9F1C0EC7373A
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCAAGBQJV5yfxAAoJEDwO/+eO4+5uNtEQAI/LjynTpOrI4BDOmuqTWhv6
2OH6KAbn+HOWRdhp4Jgj5m6ZxVxg69zj10euh/+g6S6uBdXlzgLLT1bPNV8/iroy
wkOUP6bzUNlkdQibLOZv7DektKhz8GgYFGTyYiKa8ItBd1ufeU5aT7iXLT5o7Qoo
msKwVSfPoOCgjQhMipBhn/tp+fRuT8NjCsKHnL8nGD2qv4uqIRkBi7mRcWoQkH+U
FPZnA0oxr+6N3KTBiT/d/IIfNqDUnCN3mPaXi2MLJcqMm0YZ6ZaoUZ1G9nwY2O9D
mXJVT+YftfXCf2aBYftV08KFJvVFJDhGeC2ztXkw+stFbDn+Esm4WI1aaW+lAuYP
3t9ktPo/eKaRtsWF8mDG188ae9tM2fgC+al8pyiOSv/vg0Pbkqr+paV/bjC+GESW
+3NTWCNupUX+o4pEqK99F3OHzHuVVJAcmcII7tFdqTPTBjgPdfwH1MTw+73gfN1u
TRK1xZPgH5k+eYleFgaY9rDaMe0C1WbKoEcxL5gUFwn3OihcEPjOKCIgg4liLir2
zFjxNHCb70gkWHdeYnzmThooU0bEXgfWFFzNOqbanuE7L+BWUeawzVFnJKaUKtIG
rmpYIjKRd95vx0BZO8RKtiWYOnb1Plk+RcBe4oZIhzj3PixUVV2B60LRx/SkCbjV
3cBLPRUjsoVzvd1oiwuz
=vx5Y
-----END PGP SIGNATURE-----

--Apple-Mail=_90A5B14F-3215-4C6F-8AC6-9F1C0EC7373A--
