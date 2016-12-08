From: Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: pull request: bluetooth-next 2016-12-08
Date: Thu, 8 Dec 2016 09:52:22 +0200
Message-ID: <20161208075222.GA5772@x1c.lan>
References: <20161208074809.GA4680@x1c.lan>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="SLDf9lqlvOQaIe6s"
Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20161208074809.GA4680-IWfI2fE34AE@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--SLDf9lqlvOQaIe6s
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

(resending since I forgot to sign the first one)

Hi Dave,

I didn't miss your "net-next is closed" email, but it did come as a bit
of a surprise, and due to time-zone differences I didn't have a chance
to react to it until now. We would have had a couple of patches in
bluetooth-next that we'd still have wanted to get to 4.10.

Out of these the most critical one is the H7/CT2 patch for Bluetooth
Security Manager Protocol, something that couldn't be published before
the Bluetooth 5.0 specification went public (yesterday). If these really
can't go to net-next we'll likely be sending at least this patch through
bluetooth.git to net.git for rc1 inclusion.

Johan

---
The following changes since commit 5fccd64aa44829f87997e3342698ef98862adffd:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next (2016-12-07 19:16:46 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next.git for-upstream

for you to fetch changes up to a62da6f14db79bd7ea435ab095e998b31b3dbb22:

  Bluetooth: SMP: Add support for H7 crypto function and CT2 auth flag (2016-12-08 07:50:24 +0100)

----------------------------------------------------------------
Geliang Tang (1):
      Bluetooth: btmrvl: drop duplicate header slab.h

Johan Hedberg (1):
      Bluetooth: SMP: Add support for H7 crypto function and CT2 auth flag

Stefan Schmidt (4):
      ieee802154: atusb: sync header file from firmware for new features
      ieee802154: atusb: store firmware version after retrieval for later use
      ieee802154: atusb: try to read permanent extended address from device
      ieee802154: atusb: implement .set_frame_retries ops callback

 drivers/bluetooth/btmrvl_drv.h |  1 -
 drivers/net/ieee802154/atusb.c | 79 +++++++++++++++++++++++++++++++++----
 drivers/net/ieee802154/atusb.h | 11 ++++--
 net/bluetooth/smp.c            | 85 ++++++++++++++++++++++++++++++++--------
 net/bluetooth/smp.h            |  1 +
 5 files changed, 149 insertions(+), 28 deletions(-)

--SLDf9lqlvOQaIe6s
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJYSRE2AAoJECQj9vv5qNQSKnIP/12BMzGAbyDpE5NWSC35zB0Z
p1Ujv+QwihyGD/G9l4gdyiy31NP5VSfAdd2xj9LOSLdQ7sYNf+/Pp+3FjZPb4e5c
TdGaTsHpwHPrq86+R/coOb3RV+/+wzl+dfzi6X7ZDQ8NL7n/vIkeYRMYedvGjMZU
mEq1PxeRVxaTc/fXmqwgNCWu6N+2AadnT9yQsjdES944c0NtIFuhjY1/KkbLlb/K
fVl1jhcOwb/pqu18ACuHwd81IDLtJkYHCMrfLi2YA6td60Nmc4hs9+zb2gbrbz/m
QPusygUS3Oie8Il7hr5zFQr0hL0xv/Wrn674b6h6/58Syb86oX2vEjMZ9abd3tgH
cSr8gvWavJS/UBjW0Ocni/r7JtRPSgClK6patKNjXOUEXfHN/rLAOT12j2Plydkr
pv6pC0IpLQ8QYVSY5i09Pa2Xikz9YXXJKojE/oPVDVMa92V0VI9QFv35II/spXjm
mvZ1/5RKVSDm0fA1GmIe8ZOkGLv6Y9JWbT57Liis9+At8I/sNr+eUmO1r7EKPwzL
oPDY3tnvEj+PgHhMS1IruXiNv3uI8JG8Gi7+E3+jjXWn3fwumPQqKMdG3xqHmI6v
h/jSCjSxx435vAsV+b4fqnScviGcIbWXPWGrgBubVC6L5sfERcoIcOa92Y/SsoGL
acgiuHi5THSr9YzzzY5h
=emVE
-----END PGP SIGNATURE-----

--SLDf9lqlvOQaIe6s--
