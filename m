From: Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: pull request: bluetooth 2015-12-01
Date: Tue, 1 Dec 2015 10:58:44 +0200
Message-ID: <20151201085844.GA12776@t440s.lan>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="wRRV7LY7NUeQGEoC"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--wRRV7LY7NUeQGEoC
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

Here's a Bluetooth fix for the 4.4-rc series that fixes a memory leak of
the Security Manager L2CAP channel that'll happen for every LE
connection.

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit c5a37883f42be712a989e54d5d6c0159b0e56599:

  Merge branch 'akpm' (patches from Andrew) (2015-11-10 21:14:23 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth.git for-upstream

for you to fetch changes up to 7883746bc663150e8acd7a57397fc889698b0b33:

  Bluetooth: Fix l2cap_chan leak in SMP (2015-11-11 23:48:34 +0100)

----------------------------------------------------------------
Johan Hedberg (1):
      Bluetooth: Fix l2cap_chan leak in SMP

 net/bluetooth/smp.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

--wRRV7LY7NUeQGEoC
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJWXWFDAAoJECQj9vv5qNQSbiYP/12b38DSuOGT7ZsufkSKb5Y4
z3QcNJCFkf4fOe+6HyZZKSqJKeA00YSE+x2yqsWVXyPmZ5P0bxpxR90AQb4+iRSW
o/S0zWaUeXqLqRa9HnvJGVhHj62tjt9ROFQIx0Zu+aXvKMw66KLqOP52UCj1zsKv
JNV2AcA2TxQN+8dX/RQhGlab1VE6Xr/AIxWp2r+pCufeDmoCBip+75kINGBJZW0R
n9aZkXXm1rgEaNvQgUBQRs2wgalIIz89KECdWjtGeO5Hau6jfJyZmGIj1VeA5JV/
H9F6w2AHmHDLpcqSovvXdF2s7gzv3x50zG/niVILfODViiEuqa567rnxpNHCR7HE
OdDOxvlxPbO2mbl2wd+3kOVv9UY85B+TkBrfJXTmth/BX1+vQzlCrT2033TgGUyi
xioUJc8i4Rk1bBy8wreHFxehI225RD4YdEGBtQ7icoQ2Q5DUmwcy51PeQZTGn6p4
9rUnwtxWzKWofkgB0B6zIBt/jHkO0nCOF2Yp3IB2DwvTVzcMyPzS0Ft1vKc8Gqxd
NyL3L6+TN1hX40Pz6zjR8/Ozzr/UFyKyKpTl2z/nfHimGX6VUaNZ/V71T8JVI+Sl
HcKIWlsTEJPDrkkdbTMA14/BW0TWQX8J3eCxGFa7digo43wliMquNcR0Kd7mjpKS
qnj0qzGjnz8AAx3yL2Na
=uCix
-----END PGP SIGNATURE-----

--wRRV7LY7NUeQGEoC--
