From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH net-next V3] net: ena: Add a driver for Amazon Elastic
 Network Adapters (ENA)
Date: Tue, 19 Jul 2016 20:26:44 +0300
Message-ID: <20160719172644.GK20674@leon.nu>
References: <1468478774-19942-1-git-send-email-netanel@annapurnalabs.com>
 <20160715050005.GD30603@leon.nu>
 <578E0A65.1020105@annapurnalabs.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="hl1kWnBARzJiTscN"
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, zorik@annapurnalabs.com,
	saeed@annapurnalabs.com, alex@annapurnalabs.com, msw@amazon.com,
	aliguori@amazon.com, benjamin.poirier@gmail.com,
	ben@decadent.org.uk, romieu@fr.zoreil.com, rami.rosen@intel.com,
	antoine.tenart@free-electrons.com
To: Netanel Belgazal <netanel@annapurnalabs.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <578E0A65.1020105@annapurnalabs.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--hl1kWnBARzJiTscN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jul 19, 2016 at 02:09:25PM +0300, Netanel Belgazal wrote:
>=20
>=20
> On 07/15/2016 08:00 AM, Leon Romanovsky wrote:
> > On Thu, Jul 14, 2016 at 09:46:14AM +0300, Netanel Belgazal wrote:
> >> This is a driver for the ENA family of networking devices.
> >>
> >> Signed-off-by: Netanel Belgazal <netanel@annapurnalabs.com>
> >> ---
> >>
> >> Notes:
> > ...
> >
> >>     - Increase driver version to 1.0.2
> > ...
> >
> >> +static void ena_get_drvinfo(struct net_device *dev,
> >> +			    struct ethtool_drvinfo *info)
> >> +{
> >> +	struct ena_adapter *adapter =3D netdev_priv(dev);
> >> +
> >> +	strlcpy(info->driver, DRV_MODULE_NAME, sizeof(info->driver));
> >> +	strlcpy(info->version, DRV_MODULE_VERSION, sizeof(info->version));
> > Does module version give anything valuable in real life usage?
> > Do you plan to bump version after every patch?
> >
> > Hint, NO.
>=20
> I think it is appropriate to expose driver version to ethtool, and itis a=
ppropriate to be able to version a driver in upstream (mainly for debug pur=
pose)
> I don't think there is upstream agreementthat no driver should be allowed=
 to maintain a versionnumber.

You didn't answer on my questions, so I suppose that this version
interface will be forgotten and won't be relevant after first major
rework.

You have kernel version to know which driver you are running, mixing
different versions of driver with other kernels are seeing as
not-supported by the community.

>=20
> >> +	strlcpy(info->bus_info, pci_name(adapter->pdev),
> >> +		sizeof(info->bus_info));
> >> +}
> >> +
> >> +
> > ...
> >
> >> +
> >> +static char version[] =3D
> >> +		DEVICE_NAME " v"
> >> +		DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
> >> +
> >> +MODULE_AUTHOR("Amazon.com, Inc. or its affiliates");
> >> +MODULE_DESCRIPTION(DEVICE_NAME);
> >> +MODULE_LICENSE("GPL");
> >> +MODULE_VERSION(DRV_MODULE_VERSION);
> >> +
> >> +/* Time in jiffies before concluding the transmitter is hung. */
> >> +#define TX_TIMEOUT  (5 * HZ)
> >> +
> >> +#define ENA_NAPI_BUDGET 64
> >> +
> >> +#define DEFAULT_MSG_ENABLE (NETIF_MSG_DRV | NETIF_MSG_PROBE | NETIF_M=
SG_IFUP | \
> >> +		NETIF_MSG_TX_DONE | NETIF_MSG_TX_ERR | NETIF_MSG_RX_ERR)
> >> +static int debug =3D -1;
> >> +module_param(debug, int, 0);
> >> +MODULE_PARM_DESC(debug, "Debug level (0=3Dnone,...,16=3Dall)");
> > What is it?
>=20
> This is the debugging message interface.
> https://www.kernel.org/doc/Documentation/networking/netif-msg.txt

This document was updated last time in 2006 and I doubt that it is
relevant in 2016. You have dynamic debug prints infrastructure for it,
use it.

--hl1kWnBARzJiTscN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXjmLUAAoJEORje4g2clinz6wQAIuw5LnH5lWpib+O1R/4q5Mj
7BPR6wOZW6PlYbvurYip1ospIeUHT6Gu09a0puvy1o9sbjrjLbhC08NCczaeutyu
LiNYQfFlDVlb+Yfm8GJQ62GSB7uaoES29MZ6J/36Q6rzUX+w84JClYTmbp63P/t2
y6sNUdtez9nbyti2WGIQSshrxiuC0PnTw8NaIJjNvmyQjqYipg7kSjJmPlQVZn7h
S1NScf69ghp9ytwfWWhwenNiFmnfCBl2ucJDbYm9ypqruf6yEOzuWdmp95i7PhJh
sHx/567qcGG6KSkCieT5ZCBfYegvHo0HxxYtN/6Bzsxlyf11x2tqAkntXgP0MGgi
mAiTQygH8Mkfm7171WtKQIArVK6iT9vkYkuLxaUP12LQh67HaRZlv3HBG3EFUifw
Eg4pfeaEkXvWSMXUKme4VOKTYNsKgvdbwu6JnJXO4X8ZpACNXQw6GRrhHqC14AgK
BLRgXjx9oyHs/7+s9hjm0ekjpBZyqYYA5IzDw4Job0QphXpEKzl96f6eeVxuNV7s
/vuhSb2R7TfS8PTZbrlMo3OD6LPuT5IgswZvg0hOWkg63Azdg7RNCySgTkjc7pzc
LmmtdO0WOx2XqESmKF7FhNzvaZm35yP36te7RV4LbkkT7KJ/8IAOWFrykjIYki23
4ciTq0R9LGUdALLQ0Xmf
=zETv
-----END PGP SIGNATURE-----

--hl1kWnBARzJiTscN--
