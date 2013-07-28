From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 00/12][pull request] Intel Wired LAN Driver Updates
Date: Sun, 28 Jul 2013 16:11:38 -0700
Message-ID: <1375053098.32309.28.camel@jtkirshe-mobl>
References: <1375011676-30739-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20130728.132105.1045846024944164783.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-S2LzyOU5l4lnKwa8zE8L"
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:36163 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750800Ab3G1XLk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Jul 2013 19:11:40 -0400
In-Reply-To: <20130728.132105.1045846024944164783.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-S2LzyOU5l4lnKwa8zE8L
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2013-07-28 at 13:21 -0700, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Sun, 28 Jul 2013 04:41:04 -0700
>=20
> > This series contains updates to e100 and e1000e.
> >=20
> > The e100 patch from Andy simply updates the netif_printk() to use
> > %*ph to dump small buffers.
> >=20
> > The changes to e1000e include a fix from Dean Nelson to resolve a
> > issue where a pci_clear_master() was accidentally dropped during a
> > conflict resolution. Wei Young provides 2 patches, one removes an
> > assignment of the default ring size because it was a duplicate. The
> > second changes the packet split receive structure to use
> > PS_PAGE_BUFFERS macro for the length so that problems won't occur
> > when the length is changed.
> >=20
> > The remaining patches for e1000e are from Bruce Allan, where he
> > provides a number of fixes and updates for I218.  In addition, a
> > fix for 82583 which can disappear off the PCIe bus, to resolve this,
> > disable ASPM L1.  Bruce also provides a fix to a previous commit
> > (commit e60b22c5b7 e1000e: fix accessing to suspended device) so that
> > devices are only taken out of runtime power management for those
> > ethtool operations that must access device registers.
> >=20
> > The following are changes since commit dcfe8048de66c3468060c8a2ec2c04ae=
3725d002:
> >   bonding: remove bond_resend_igmp_join_requests read_unlock leftover
> > and are available in the git repository at:
> >   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next maste=
r
>=20
> Pulled, thanks a lot Jeff.

It looks like you pulled my net tree instead of my net-next tree.
Fortunately, I did not have anything applied to my net tree that had not
already been sent out.

--=-S2LzyOU5l4lnKwa8zE8L
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJR9aUqAAoJEOVv75VaS+3OgvoQAJpLdETZefsqPSshzs+MY/W/
7QurQHSLwvgVg2ia5HflLM8IQ1l8z4nPkecfHOz4H/nsy3+43DSgpD/JakiY2AZy
3yRpoxnQOxVt5i1yn3pJBRk8+T3se6Iw2Z77JVpfld661l7u9iJdapTa9s45dilS
ibFK+IW6SiYbVfxzUqYYewZzfu1i/p0ZLDxZtmK4RkjpijmjDJCaS9X6mdlUUYDn
rmCx21yzeS6IQXFvXObf2TTliMD8nXKmpSEY+RmzcAOK9xo/d4h/aiAw2mHZVmYx
lJjNEJEK/te7yFgpc3eHTS7itJJM2klJcf99QKw2/FMW0LHKYarHSxbPcwJNXSDA
ajgvK/mO21nLMMxJt+cVncrEvALeeCs8bj7XTKjM46rjjaNLFMgpvkznFXXbRp+b
eYQEhd/96hSvRyufMhDPgL57D0ixRb74dw57pyDZlFNVlxmvh17IuzY+05XEzUrW
LEdQ9I8gaIeI5dLvElJcMXW4ght8jXI/TulCYOu3NHSsPAkWMycS08KwoMMWtQNc
Wx7g0FZWO2sa1ZxxzMIn3vWLkFqzDigaugdGR6bmUiZECDEp/m4Zzn0Y3ZKEEeuo
dOnfO9/fh586No6ZUQCeV1dZnyFXCvPTtfEfOf9hS6Pfw3Pp0qbHg7/vJm9ltg+F
1FJq3hV2tIDkGQ0NmE4X
=55x9
-----END PGP SIGNATURE-----

--=-S2LzyOU5l4lnKwa8zE8L--
