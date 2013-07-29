From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 00/12][pull request] Intel Wired LAN Driver Updates
Date: Sun, 28 Jul 2013 19:08:55 -0700
Message-ID: <1375063735.32309.32.camel@jtkirshe-mobl>
References: <1375011676-30739-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20130728.132105.1045846024944164783.davem@davemloft.net>
	 <1375053098.32309.28.camel@jtkirshe-mobl>
	 <20130728.172022.2147023715179571146.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-7u8HKrV/9yZcU4QwPBdO"
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:37911 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752189Ab3G2CI5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Jul 2013 22:08:57 -0400
In-Reply-To: <20130728.172022.2147023715179571146.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-7u8HKrV/9yZcU4QwPBdO
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2013-07-28 at 17:20 -0700, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Sun, 28 Jul 2013 16:11:38 -0700
>=20
> > On Sun, 2013-07-28 at 13:21 -0700, David Miller wrote:
> >> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >> Date: Sun, 28 Jul 2013 04:41:04 -0700
> >>=20
> >> > This series contains updates to e100 and e1000e.
> >> >=20
> >> > The e100 patch from Andy simply updates the netif_printk() to use
> >> > %*ph to dump small buffers.
> >> >=20
> >> > The changes to e1000e include a fix from Dean Nelson to resolve a
> >> > issue where a pci_clear_master() was accidentally dropped during a
> >> > conflict resolution. Wei Young provides 2 patches, one removes an
> >> > assignment of the default ring size because it was a duplicate. The
> >> > second changes the packet split receive structure to use
> >> > PS_PAGE_BUFFERS macro for the length so that problems won't occur
> >> > when the length is changed.
> >> >=20
> >> > The remaining patches for e1000e are from Bruce Allan, where he
> >> > provides a number of fixes and updates for I218.  In addition, a
> >> > fix for 82583 which can disappear off the PCIe bus, to resolve this,
> >> > disable ASPM L1.  Bruce also provides a fix to a previous commit
> >> > (commit e60b22c5b7 e1000e: fix accessing to suspended device) so tha=
t
> >> > devices are only taken out of runtime power management for those
> >> > ethtool operations that must access device registers.
> >> >=20
> >> > The following are changes since commit dcfe8048de66c3468060c8a2ec2c0=
4ae3725d002:
> >> >   bonding: remove bond_resend_igmp_join_requests read_unlock leftove=
r
> >> > and are available in the git repository at:
> >> >   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next ma=
ster
> >>=20
> >> Pulled, thanks a lot Jeff.
> >=20
> > It looks like you pulled my net tree instead of my net-next tree.
> > Fortunately, I did not have anything applied to my net tree that had no=
t
> > already been sent out.
>=20
> No, really, I did this:
>=20
> git pull git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next =
master

Disregard, it was me misreading my git log in my net tree after updating
it against your latest tree.

When will your kernel.org net-next be updated?  I ask because I have a
series for ixgbe I am putting together and wanted to make sure it is
against the latest net-next.

--=-7u8HKrV/9yZcU4QwPBdO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJR9c63AAoJEOVv75VaS+3OHlcQAIuLyl/Oc/3hE603v7QlLEpK
Z7L+hUPmpYehcqkBMD89iz2cgFG+yzg0E9FLE3HvaxBsqjIuEeWWSmeR0liMuwpq
in/NwgyAFn8mPWS7Uh4O4lGpBH9c/RBnQFtcly1eIDI7b6vVxSC0EvSNcHu7gwNp
pcUkVHnkneLAkRUD6K9Dx+xwsAKcEb9KNKMPK1n2enEVEu44qKu9RXs03QcI/ibc
W0OEwpneLDJqD3JSrTZ06zZ4DbeqfuzPHaKVjMf+4d/msLi2vJhjRvica7osTQg6
1R2OHieU/gaKJLIulx3Vt/9WKfIdDGYZVrOrSib3dLRsj6fxFmEs90yHfE02CmAi
JfAuJublgnbYFU6I0e0xnd6/K0Tsf3Tcp2vOsX3JXV1wJOGfpdKB5MCQluRF1v7j
e/BNnzIaxD3eLwkFa+Utt87+2VPSarR6sZSfDdy0NR7qnPBqHTlikGDmr8c/RdgQ
/YsSYEI8F4uQykWD/xKiSq5bvVsFINXpEKUGfJcqoqxGFiQUCgynJj7mq8r0kkGI
kOG7Yk7Nun/kuWsl2ofUx0UB+D94gEm4DWYsMZfxUg5dOQbr/e7W9vqwHA8HrcYC
1OtJ1e4TNByQC1+wG8L0Ph+JgRLGluI7TnieqdCiWUM/ERcS1BXNHY0bE6EQjV2l
bveWhIdIMG00+TP6fs61
=+TlM
-----END PGP SIGNATURE-----

--=-7u8HKrV/9yZcU4QwPBdO--
