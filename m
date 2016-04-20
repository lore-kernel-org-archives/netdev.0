From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [Intel-wired-lan] [PATCH net-next V5 2/2] intel: ixgbevf:
 Support Windows hosts (Hyper-V)
Date: Tue, 19 Apr 2016 23:24:42 -0700
Message-ID: <1461133482.2923.28.camel@intel.com>
References: <1461118655-28103-1-git-send-email-kys@microsoft.com>
	 <1461118677-28142-1-git-send-email-kys@microsoft.com>
	 <1461118677-28142-2-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Kkir4QACtr8b7lCaI9xB"
To: "K. Y. Srinivasan" <kys@microsoft.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com,
	jasowang@redhat.com, eli@mellanox.com, jackm@mellanox.com,
	yevgenyp@mellanox.com, john.ronciak@intel.com,
	intel-wired-lan@lists.osuosl.org, alexander.duyck@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461118677-28142-2-git-send-email-kys@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-Kkir4QACtr8b7lCaI9xB
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2016-04-19 at 19:17 -0700, K. Y. Srinivasan wrote:
> On Hyper-V, the VF/PF communication is a via software mediated path
> as opposed to the hardware mailbox. Make the necessary
> adjustments to support Hyper-V.
>=20
> Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
> ---
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0V2: Addressed most of the=
 comments from
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 Alexan=
der Duyck <alexander.duyck@gmail.com>
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 and Ru=
stad, Mark D <mark.d.rustad@intel.com>.
>=20
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0V3: Addressed additional =
comments from
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 Alexan=
der Duyck <alexander.duyck@gmail.com>
>=20
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0V4: Addressed kbuild erro=
rs reported by:
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 kbuild=
 test robot <lkp@intel.com>
>=20
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0V5: Addressed additional =
comments from
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 Alexan=
der Duyck <alexander.duyck@gmail.com>

First I commend you on actually making a proper changelog for a patch.
=C2=A0The only issue I have is that the changelog provides not actual
changes. =C2=A0Saying you reacted to comments does not summarize what the
actual changes were. =C2=A0I purposely did not review the earlier versions
because by the time I went to do a review, there was another version
already submitted. =C2=A0So your changelog requires that users look at all
the previous emails to actually see what Alex and Mark requested in
changes.

I am telling you this for future patches, it will not impact these
patches, just really disappointing. =C2=A0I will take the extra time to
track down all the previous emails and the changes requested to ensure
you made all the changes that were requested of you. :-( =C2=A0This will
just delay when I apply the patches for testing.

>=20
> =C2=A0drivers/net/ethernet/intel/ixgbevf/ixgbevf.h=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 |=C2=A0=C2=A0 12 ++
> =C2=A0drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |=C2=A0=C2=A0 31 =
+++-
> =C2=A0drivers/net/ethernet/intel/ixgbevf/mbx.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0 |=C2=A0=C2=A0 12 ++
> =C2=A0drivers/net/ethernet/intel/ixgbevf/vf.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 |=C2=A0 216
> +++++++++++++++++++++
> =C2=A0drivers/net/ethernet/intel/ixgbevf/vf.h=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 |=C2=A0=C2=A0=C2=A0 2 +
> =C2=A05 files changed, 266 insertions(+), 7 deletions(-)

--=-Kkir4QACtr8b7lCaI9xB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXFyCqAAoJEOVv75VaS+3OXs0QAIhD7cnzNvXnaxpJtQCEPHw0
X9pHxLNsm8tDkEvA5LesQN+03SD8APowE6OO5oe7ZOM2XenOTMpsiPpKOcQWR0tQ
3sZCADEVzelHoox1erppIlhjb2BG3HsZNNJ87TsAQNmbs5iLatFtAgct/PC+w3rc
xvjjIdV652oY6yX38/a2BVQwACtZIz1PgGa2d2LBL3TQi5/6frXNfVgiVfSOe3DP
EOBp3Jk6aG8hfyrFupOKzOXI8nXVaCeD+YgJvKdOrEwXi+LC8BXCtw2dLoCv7lq9
A0mqn1i+A+nXV1DOZ3HBvv0iJ+DKNd5abRSVlU/VxW+lrB3hyTRQYeRlt6BpSJhM
Q1/I8QNt+eJmI7+jyKNaKsfyP3qjo6E8msIGFVeM0DpCRVBUJIcTdE6yNzoCyAl4
n/BKAvt9b++m7KfXg1n2I5QE6o7R1/PU04uInuMK0988vC1vLtA9mAL53xh/Fdr8
YJIoTMoTMXvXZGBOx/QB23T4usAd7EHHtYlFYpmvy2uXAXh3ByF1bJMk5opeE4OT
HYL8f+H4phxSzrAZhyaE9bHpT/JJqZUexNfUZZlpOBBVhLpwSiNQIqR3STd2+/6L
HEq0JBVdPxBhVclcSQkevCorFJyC3Is0psgU0ah88ngBevYo8s7MM/cY1hIhmJR6
dKtPxpE/8GRE+9+YpvIR
=aiXL
-----END PGP SIGNATURE-----

--=-Kkir4QACtr8b7lCaI9xB--
