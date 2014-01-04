From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next] pci_regs.h: Add PCI bus link speed and width defines
Date: Fri, 03 Jan 2014 17:27:39 -0800
Message-ID: <1388798859.2275.5.camel@jtkirshe-mobl>
References: <CAErSpo7K3OBuTEZrXmhQ3iXtLf3M5JNnEqmAvaceroJ46VAOKg@mail.gmail.com>
	 <20140103.185607.1380379872647540168.davem@davemloft.net>
	 <CAErSpo7TJXTCxpFKWXLTaHmqXXnYQdnpNeWt+cehSaES2Jh30w@mail.gmail.com>
	 <20140103.193008.684316024702680161.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-bc8+RZ/we7a+7iRUIBQh"
Cc: bhelgaas@google.com, jesse.brandeburg@gmail.com,
	linux-pci@vger.kernel.org, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	linux-kernel@vger.kernel.org, bjorn.helgaas@hp.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20140103.193008.684316024702680161.davem@davemloft.net>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-bc8+RZ/we7a+7iRUIBQh
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-01-03 at 19:30 -0500, David Miller wrote:
> From: Bjorn Helgaas <bhelgaas@google.com>
> Date: Fri, 3 Jan 2014 17:00:42 -0700
>=20
> > On Fri, Jan 3, 2014 at 4:56 PM, David Miller <davem@davemloft.net> wrot=
e:
> >> From: Bjorn Helgaas <bhelgaas@google.com>
> >> Date: Fri, 3 Jan 2014 15:15:57 -0700
> >>
> >>> However, I do raise my eyebrows a bit at drivers that poke around in
> >>> the PCIe capability.  I would prefer to have PCI core interfaces that
> >>> handle that instead.  But I haven't seen Jeff's changes yet.
> >>
> >> The changes just read the link status to interpret the speed at which
> >> the PCI-E link is running at.
> >=20
> > Several drivers want to do that.  It'd be nice if somebody abstracted
> > that out somehow.  Jacob added pcie_get_minimum_link() which is
> > similar.  But maybe Jeff needs something more in this case.
> >=20
> > In any case, it's not a blocker for this patch.
>=20
> Ok.
>=20
> Jeff, please merge this via the Intel submission process and don't forget
> to add Bjorn's ACK.
>=20
> Thanks.

Ok, will do.  What do you want to do with the current series of patches
(mainly the ixgbe LER patches) on my tree?  I know that there is a
thread going on between Joe Perches and Mark, but it sounded like Mark
is working on a follow-on patch to address Joe's concerns.

Guess I want to know if I leave my tree alone for you to pull or toss
the current pull request series and get the i40e series applied.

Cheers,
Jeff

--=-bc8+RZ/we7a+7iRUIBQh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJSx2OLAAoJEOVv75VaS+3OD0YQAJYpxBJNhXgmwleu7tbOAbUU
1W2HBbDfZmBt6AnQb12HqPDYcoGUedYEYUf/PCwBJhSEqcRkOKOCypQ9SXS7rodv
CDyD0HmYgh73xgeSj8KHz4auWhqQ/YmrOWCegFzl+E81vgsqCad+K6geN7Gd4Y6Q
DLrsl9y8s2llbky96NI8/UbJAgQvyml3oxEi+ylXiAp+Ct2DOsJ9ddJM29fM944N
BYPZQft1Fc9wVK4G12cHtB0ebCnx8+jAU/IPjobOGL0Tbpx6HfeN/KQJ1WAYnd0c
R4HCndqYjqf2cQMRJ8jLKmhIWUlD8jvdE19oJ+lsbTuF0CXBB7AFS6CAbSTZ8/NJ
d8x+k2Dy1LlxIf2u6uOX9QkMdJckIsoJ8U6DClnbxYzEHpDzF47ewsI+0lWx4h7S
vBk2UaxU7esIzDQTX9dCIy9Vl4c7htQMdkxCqvdy2YFDL2XpW8iUJ+eResClA5oO
KEIaOq65B4K/HLQSiFaZYhAJKM5L0F08QxoxmdgugNsF3UG33kFAsKm1KJTb5zap
ARlTM+1GK3+5dwVV8a+PxKkXBj60z+ZQg/lhrhkj0hTEkAKc0Shapcgv2Jcn/1t8
negrW1A8pHb9KhSsYrXyE4x6Ur3TxBlNBKqzO2jkzOdrqx1kob9uH9edysO9L2qo
P5EcvYhxN2ljxx7fDpc6
=1RgL
-----END PGP SIGNATURE-----

--=-bc8+RZ/we7a+7iRUIBQh--
