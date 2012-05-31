From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH RFC] virtio-net: remove useless disable on freeze
Date: Thu, 31 May 2012 18:35:08 +1000
Message-ID: <20120531183508.f426eb25fe1b94139c637348@canb.auug.org.au>
References: <20120404091954.GA3776@redhat.com>
	<20120528125325.GA22576@redhat.com>
	<87r4u2dllo.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5160368279981255205=="
Cc: kvm@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, Amit Shah <amit.shah@redhat.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <87r4u2dllo.fsf@rustcorp.com.au>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

--===============5160368279981255205==
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__31_May_2012_18_35_08_+1000_mGGj9zYT=zxyfc/k"

--Signature=_Thu__31_May_2012_18_35_08_+1000_mGGj9zYT=zxyfc/k
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

On Wed, 30 May 2012 19:41:47 +0930 Rusty Russell <rusty@rustcorp.com.au> wr=
ote:
>
> On Mon, 28 May 2012 15:53:25 +0300, "Michael S. Tsirkin" <mst@redhat.com>=
 wrote:
> > On Wed, Apr 04, 2012 at 12:19:54PM +0300, Michael S. Tsirkin wrote:
> > > disable_cb is just an optimization: it
> > > can not guarantee that there are no callbacks.
> > >=20
> > > I didn't yet figure out whether a callback
> > > in freeze will trigger a bug, but disable_cb
> > > won't address it in any case. So let's remove
> > > the useless calls as a first step.
> > >=20
> > > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> >=20
> > Looks like this isn't in the 3.5 pull request -
> > just lost in the shuffle?
> > disable_cb is advisory so can't be relied upon.
>=20
> I always (try to?) reply as I accept patches.
>=20
> This one did slip by, but it's harmless so no need to push AFAICT.
>=20
> Applied.

This patch exists in two trees in linux-next already ... Davem's net tree
(so presumably he will send it to Linus shortly) and Michael's vhost tree
(is that tree needed any more?).  Presumably it is now also in the rr
tree?

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Thu__31_May_2012_18_35_08_+1000_mGGj9zYT=zxyfc/k
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJPxy08AAoJEECxmPOUX5FE5/sP/RWjfggpLyTmSrN4+KiLppww
0/frDP2sJjKeQSCpxYsuc5mi8SuhgXUVxIAK1mpBL/5+51Cki32kzb2sOutZrPMc
Z3jMYkOMyP1R0VLFScJtls9D0Wth3SrnG8EXDF6ozlKi4SZ6LQQfaoT15HWp21TD
ZWPLbiiPTQmTd0CVRseinmi9CLHM15fRBQ+ST/m5nZX+hTpPbCdyHwHVfGMl8rwI
4KOtPihw6VbKFcAIGtW/3VczZmeVIi1LMDHpnJ/n1+dbLFlg6BDCx999JsccH47/
Nbqnsn0OKWFXt2DPwratdJtuBIkGHGhPolZzHtpg0PYX7tALkPR0DxbPG/6WRSvj
ySkk19xRcIsXg7qHrjhYtLUsIaZOfbl9Ov9IzlN7u/qais1Cst4cHmoNkPkwZheE
7ifcpa78SLG4kTqSA2rsoxvUcUui8YM4Z8Ytozo7UcHFxrwsK4/Osz9OTinRkeB0
0+SpQLiGbjJcNQVOP8kQUAQasiEk15SqqfvXOogkfIurgleOS3zhRq12+Ko8wnuZ
7hkv3Up4GegsTH93lIl61cdAfhYzYueTEQvwBaMYRKFyIDsBR29/7tH1Gmu5rBj2
ErcrsEa//H7sN3mVVXqdC+Mxkuyc5ekXTUa86sDdFmgZBObyEY+7FJluDwDiIhZ8
iRwCHw6P+rw5Hc8DZtgE
=0znk
-----END PGP SIGNATURE-----

--Signature=_Thu__31_May_2012_18_35_08_+1000_mGGj9zYT=zxyfc/k--

--===============5160368279981255205==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/virtualization
--===============5160368279981255205==--
