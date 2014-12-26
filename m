From: Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: pull request: bluetooth 2014-12-26
Date: Fri, 26 Dec 2014 20:15:39 +0200
Message-ID: <20141226181539.GA27027@t440s.P-661HNU-F1>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="2fHTh5uZTiUOsy+g"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--2fHTh5uZTiUOsy+g
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

Here's one more bluetooth pull request for 3.19. We've got two fixes:

 - Fix for accepting connections with old user space versions of BlueZ
 - Fix for Bluetooth controllers that don't have a public address

Both of these are regressions that were introduced in 3.17, so the
appropriate Cc: stable annotations are provided.

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit 71bb99a02b32b4cc4265118e85f6035ca72923f0:

  Bluetooth: bnep: bnep_add_connection() should verify that it's dealing with l2cap socket (2014-12-19 13:48:27 +0100)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth.git for-upstream

for you to fetch changes up to 6a8fc95c87110a466ee81675b41170b963f82bdb:

  Bluetooth: Fix accepting connections when not using mgmt (2014-12-24 20:02:00 +0100)

----------------------------------------------------------------
Johan Hedberg (1):
      Bluetooth: Fix accepting connections when not using mgmt

Marcel Holtmann (1):
      Bluetooth: Fix controller configuration with HCI_QUIRK_INVALID_BDADDR

 net/bluetooth/hci_event.c | 16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)


--2fHTh5uZTiUOsy+g
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUnaXLAAoJECQj9vv5qNQS2nwP/jhh2/zhKwyKgrUfpihyvBmG
5X/aET9N5BA7WXZR3JdqlNobb0fUWYSN5Jl6UpaYO5BSReeGMCHm76qMkou17lkB
uUTA9ouRcI4KNA4seL0ZOwvhdJfIC2EUnQeDq7EkWeSqT+Jlz/T+0pdP6ZWEtxZX
Vyt+rvdvMKgaTagMyWea0wcOebVBFTAwTPaD84Q/zFSU2oK4zz6QUyfqX1v50WLb
jH5B8Aau6YX7llZzrHLVMCltCoD9hcC9/Iox77qywwveSu8p3y4rNXDnOzLdAH8o
fdObOsuMsLdesMJpQucm606zBrXsycFmNsLP01yMHp+ZSZGLTPSu+kEDuq2MwYGP
8UOvvhg1nidAFa2Qgt6VV6NcvsSer4MhBAIlBCar8WewobZccQ2Tc772JD8z3kzE
rYgiUWjh2wmXJK0qYeLmkp9lMOoIV25JvMfQQ10S2GUEVOx5+HCw2/NwGMec/Ug3
JekGJKXZE1RhELPgehOUWoq8sn+88NTiNN75UZq1KeWBcr5YlnZ3erkTkybkg9kW
OK3+1TnIRopCglrvHj2cxXdu8hHgej53TjjfnPTG/dIAcL/37RyjpgwshOZiOtlG
UQ/wLx9DHIBq90MsOU0aCNzWS/IXgYc5Yfp6V+LEFxgmrz3OdKkUV4xqvApOxJzc
44D4JYAvE6JrxzIsMVuf
=6iKU
-----END PGP SIGNATURE-----

--2fHTh5uZTiUOsy+g--
