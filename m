From: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH] net: allwinner: emac: Add missing free_irq
Date: Tue, 10 Dec 2013 18:52:05 +0100
Message-ID: <20131210175205.GA3651@lukather>
References: <1386415902-32697-1-git-send-email-maxime.ripard@free-electrons.com>
 <52A35361.8090608@cogentembedded.com>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="DocE+STaALJfprDB"
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Return-path: <linux-sunxi+bncBD2ZNBF5VYJRB55KTWKQKGQEGCBNNCQ-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <52A35361.8090608-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org


--DocE+STaALJfprDB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Sat, Dec 07, 2013 at 08:57:05PM +0400, Sergei Shtylyov wrote:
> Hello.
>=20
> On 07-12-2013 15:31, Maxime Ripard wrote:
>=20
> >The sun4i-emac driver uses devm_request_irq at .ndo_open time, but relie=
s on
> >the managed device mechanism to actually free it. This causes an issue w=
henever
> >someone wants to restart the interface, the interrupt still being held, =
and not
> >yet released.
>=20
> >Fall back to using the regular request_irq at .ndo_open time, and introd=
uce a
> >free_irq during .ndo_stop.
>=20
> >Signed-off-by: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
> >---
> >Hi David,
>=20
> >It would be great if this patch would be applied to 3.13.
>=20
> >Thanks,
> >Maxime
>=20
>=20
> >  drivers/net/ethernet/allwinner/sun4i-emac.c | 6 ++++--
> >  1 file changed, 4 insertions(+), 2 deletions(-)
>=20
> >diff --git a/drivers/net/ethernet/allwinner/sun4i-emac.c b/drivers/net/e=
thernet/allwinner/sun4i-emac.c
> >index 50b853a..38aba50 100644
> >--- a/drivers/net/ethernet/allwinner/sun4i-emac.c
> >+++ b/drivers/net/ethernet/allwinner/sun4i-emac.c
> >@@ -717,8 +717,8 @@ static int emac_open(struct net_device *dev)
> >  	if (netif_msg_ifup(db))
> >  		dev_dbg(db->dev, "enabling %s\n", dev->name);
> >
> >-	if (devm_request_irq(db->dev, dev->irq, &emac_interrupt,
> >-			     0, dev->name, dev))
> >+	if (request_irq(dev->irq, &emac_interrupt,
> >+			0, dev->name, dev))
>=20
>    Doesn't it fit into single line?

Hmmm, yes, probably.

I'll send a v2.

Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com

--DocE+STaALJfprDB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAEBAgAGBQJSp1TFAAoJEBx+YmzsjxAgal4QALzA8nqCyoYkCsQFUcty6rne
KXR92Sr2XgmUp0OMsSpMxUl27AkoTJyE9TtsKkL0AX/v45H3GYwAGpZBi0IRA5iD
5ZU7m2s6u8RyqdUxRVT9ZVQ3olAJ/8dFvmsQh69ND7jDsYuGaCmjYq7xAWmFR8KR
im0qGvoYOVJql9BfvbDo1Z+VHro2hoxVDmSl5ue/hH1ONbbVoMRsuTc9zSW4FYzX
sziQwKvah4l+dckHkW+8HVE5PL7UB8u/3zOAc6WumAAQVsPJMsvnhvVVkCXFKEfS
ITKkBEGUhUH4ZKLHBa08PyLytr/enqGMNIDBXN/mpsRtEyLhUIcQCtrFB9nnhFSV
h0ignXTp+PG6kg3otULcFIKuNWnFZrNlfYjSqKrRggo2Jene9QclA76KGJpxIyQZ
VCmvXhZuPQmloMv7UBK2oinziG7d+AW3giVy0DIiSU45PnkMYNnSCsmBO8BH+hCQ
FmkCefNsz1CYjTCJIN++eRXMl0N9wXvsVynGQOOjUfREAL2hGNWGwkJW190t+9eY
Klvn81ci86n0oIQZglqz1Nq3Ktgy1Oy/+4WbZuTUS/D9NM02zUIMn5VaPeUam/EJ
C5kz9U0rxjxbt9U2ODXQHnWguCK/iLRP5/7N3DQM+5u5sEzC6WIVcmpnAxgAM9XT
DGdt+eMF/mm8jDKXUn2G
=wC2S
-----END PGP SIGNATURE-----

--DocE+STaALJfprDB--
