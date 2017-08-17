From: Thierry Reding <thierry.reding@gmail.com>
Subject: Re: [PATCH net] PCI: fix the return value for the
 pci_find_pcie_root_port()
Date: Thu, 17 Aug 2017 15:30:12 +0200
Message-ID: <20170817133012.GC6854@ulmo>
References: <1502936730-7368-1-git-send-email-dingtianhong@huawei.com>
 <20170817105156.GA18789@ulmo>
 <ea83e7a8-39a4-5b94-1148-5bf4ae4ed214@huawei.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="6zdv2QT/q3FMhpsV"
Cc: leedom@chelsio.com, ashok.raj@intel.com, bhelgaas@google.com,
        helgaas@kernel.org, werner@chelsio.com, ganeshgr@chelsio.com,
        asit.k.mallick@intel.com, patrick.j.cramer@intel.com,
        Suravee.Suthikulpanit@amd.com, Bob.Shaw@amd.com,
        l.stach@pengutronix.de, amira@mellanox.com,
        gabriele.paoloni@huawei.com, David.Laight@aculab.com,
        jeffrey.t.kirsher@intel.com, catalin.marinas@arm.com,
        will.deacon@arm.com, mark.rutland@arm.com, robin.murphy@arm.com,
        davem@davemloft.net, alexander.duyck@gmail.com,
        eric.dumazet@gmail.com, linux-arm-kernel@lists.infradead.org,
        netdev@vger.kernel.org, linux-pci@vger.kernel.org,
        linux-kernel@vger.kernel.org, linuxarm@huawei.com
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <ea83e7a8-39a4-5b94-1148-5bf4ae4ed214@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--6zdv2QT/q3FMhpsV
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Aug 17, 2017 at 08:40:16PM +0800, Ding Tianhong wrote:
>=20
>=20
> On 2017/8/17 18:51, Thierry Reding wrote:
> > On Thu, Aug 17, 2017 at 10:25:30AM +0800, Ding Tianhong wrote:
> >> The pci_find_pcie_root_port() would return NULL if the given
> >> dev is already a Root Port, it looks like unfriendly to the
> >> PCIe Root Port device, Thierry and Bjorn suggest to let this
> >> function return the given dev under this circumstances.
> >>
> >> Fixes: 0e405232871d6 ("PCI: fix oops when try to find Root Port for a =
PCI device")
> >> Suggested-by: Thierry Reding <thierry.reding@gmail.com>
> >> Suggested-by: Bjorn Helgaas <helgaas@kernel.org>
> >> Signed-off-by: Thierry Reding <thierry.reding@gmail.com>
> >> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> >> ---
> >>  drivers/pci/pci.c | 2 +-
> >>  1 file changed, 1 insertion(+), 1 deletion(-)
> >>
> >> diff --git a/drivers/pci/pci.c b/drivers/pci/pci.c
> >> index 7e2022f..352bb53 100644
> >> --- a/drivers/pci/pci.c
> >> +++ b/drivers/pci/pci.c
> >> @@ -514,7 +514,7 @@ struct resource *pci_find_resource(struct pci_dev =
*dev, struct resource *res)
> >>   */
> >>  struct pci_dev *pci_find_pcie_root_port(struct pci_dev *dev)
> >>  {
> >> -	struct pci_dev *bridge, *highest_pcie_bridge =3D NULL;
> >> +	struct pci_dev *bridge, *highest_pcie_bridge =3D dev;
> >> =20
> >>  	bridge =3D pci_upstream_bridge(dev);
> >>  	while (bridge && pci_is_pcie(bridge)) {
> >=20
> > I think this should actually be this change on top of a revert of commit
> > 0e405232871d6 ("PCI: fix oops when try to find Root Port for a PCI
> > device"). After the above change, the previous fix will have a redundant
> > check because highest_pcie_bridge will never be NULL.
> >=20
> > Let me send out that version to clarify what I mean.
> >=20
>=20
> Hi Thierry:
>=20
> The patch ("PCI: fix oops when try to find Root Port for a PCI device")
> has been merge to the linus mainline tree before you found this deficienc=
ies....

I understand that. I'm just saying that there's no point keeping that
change around because it no longer makes sense after we initialize the
highest_pcie_bridge variable to dev.

Thierry

--6zdv2QT/q3FMhpsV
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiOrDCAFJzPfAjcif3SOs138+s6EFAlmVmmQACgkQ3SOs138+
s6GTPRAAoSwdaH5DW037ri1B/DhwK8lAA0pTLkjBJvE/ZbVzvDG5p91r8+geOINb
VGxW2WyLOspLiXbIb7w14bgyTlQg/RPDIF762W6XSLbQAFEkAooP6uMPLi2t7ajZ
EOkT3VDW4rtrpyXiUW0i5vAx3Pkljee4mCLYiLP7FyiIwAYMCrJaLKo/YXsG5Yw0
xMtAYeZ8GJCC9cxsvj7BBuHLrHdnr4EqgQ/eNF+yJCkyBf4A9JIrqoC7AAxQCD2a
BJZ8DNwGqApJCTnQUvALFT6jeAx/j5BKAmROwUD9t29Tk4xDRrZ3f7E4WBvMASNA
FXXxYFagtOXrNiB2Tkhhc95J+7H0wrbqmYlM2afagrARzsJttfvLcAhu2jN1QVlK
s2eaqxJqLSbj2MEPO7Awa9xzTsJE0CKFKDt62PXdpiDU1GFSMGHXAbyyCqErHRXG
7uqUeNtX0KHUdL4RTz7fQYAG6FzKKhRAgvGIYzjIYzETqGoALAIWLurj9b/kTmGl
q1rqL7P91cGm2ThL7VKhGfLKWzg8Mbyn6mgBrdJYHNEedUAea+u1DTRxR0pfnJ3u
4CiRPAjmF6lFiBeLPyCg4jj9WVNMxVTIcwNYfjGPXuTzNqgFcAOHQNJjH3VpCJ0c
Y5BASVCzt0DiVuEEOMiTagLc8shw3kJ+XlRzCdlOigS6rrO8ggU=
=vIZt
-----END PGP SIGNATURE-----

--6zdv2QT/q3FMhpsV--
