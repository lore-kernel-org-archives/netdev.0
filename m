From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [PATCH V3 0/2] pci: Provide a flag to access VPD through
 function 0
Date: Fri, 26 Jun 2015 18:04:21 +0000
Message-ID: <8CB0ECE7-CFE2-43CB-BA60-2E2E0A34D5D1@intel.com>
References: <20150603184445.109080.36387.stgit@mdrustad-wks.jf.intel.com>
 <051B68B4-3E77-4EB0-B9FE-8523631884A2@intel.com>
 <45099CC7-DDAB-41D9-AB74-5A81E2AAF64C@intel.com>
 <CAErSpo7e-QtQQTj2yh_jG07vqU1j1YBez_9wrcrzOQs7+eDFng@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_165B12A1-5D1D-4E3C-B606-C317F013CCB4";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.duyck@gmail.com>
To: Bjorn Helgaas <bhelgaas@google.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <CAErSpo7e-QtQQTj2yh_jG07vqU1j1YBez_9wrcrzOQs7+eDFng@mail.gmail.com>
Content-Language: en-US
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Apple-Mail=_165B12A1-5D1D-4E3C-B606-C317F013CCB4
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

> On Jun 17, 2015, at 9:44 AM, Bjorn Helgaas <bhelgaas@google.com> =
wrote:
>=20
> On Wed, Jun 17, 2015 at 11:29 AM, Rustad, Mark D
> <mark.d.rustad@intel.com> wrote:
>> + Alex
>>=20
>>> On Jun 5, 2015, at 2:59 PM, Rustad, Mark D <mark.d.rustad@intel.com> =
wrote:
>>>=20
>>>> On Jun 3, 2015, at 11:46 AM, Mark D Rustad =
<mark.d.rustad@intel.com> wrote:
>>>>=20
>>>> Many multi-function devices provide shared registers in extended
>>>> config space for accessing VPD. The behavior of these registers
>>>> means that the state must be tracked and access locked correctly
>>>> for accesses not to hang or worse. One way to meet these needs is
>>>> to always perform the accesses through function 0, thereby using
>>>> the state tracking and mutex that already exists.
>>>>=20
>>>> To provide this behavior, add a dev_flags bit to indicate that this
>>>> should be done. This bit can then be set for any non-zero function
>>>> that needs to redirect such VPD access to function 0. Do not set
>>>> this bit on the zero function or there will be an infinite =
recursion.
>>>>=20
>>>> The second patch uses this new flag to invoke this behavior on all
>>>> multi-function Intel Ethernet devices.
>>>>=20
>>>> Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
>>>>=20
>>>> ---
>>>> Changes in V2:
>>>> - Corrected a spelling error in a log message
>>>> - Added checks to see that the referenced function 0 is reasonable
>>>> Changes in V3:
>>>> - Don't leak a device reference
>>>> - Check that function 0 has VPD
>>>> - Make a helper for the function 0 checks
>>>> - Moved a multifunction check to the quirk patch
>>>=20
>>> So does this series look acceptable now? I think I addressed the =
issues that Alex raised. Can these also be considered for -stable?
>>=20
>> More than a week has passed without any comment. Is this going to be =
accepted or is there still an issue?
>=20
> Sorry, Mark, I've just been busy with other issues and haven't had a
> chance to look at this yet.

Is there any chance of this getting into this merge window?

--
Mark Rustad, Networking Division, Intel Corporation


--Apple-Mail=_165B12A1-5D1D-4E3C-B606-C317F013CCB4
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCAAGBQJVjZQkAAoJEDwO/+eO4+5u+S4P/39Fau9TPpLocOuAkdxDJBoH
x/i9BHxbBQPCwd12O5eu2G7XX+xPQJddPv4rV5HpA5+Uzx1Ry2q0+SEEgRt76iKp
qBtKUKn/jnA8YUM7YAkjaKGfNicKO0EE5EQVfGfU2uEsa82qjTRBTC3jh1T6/DJH
EDZv1WTQW0SUhZc4OHmW83JrLCfpwrR8DVdi/xb5CXkSIVb957DRmwahKBa/1HpO
PNlyAe23Q3RBrESCCNlHDlqfj1C+0HJMyPSduk7Bt9/m0qZrAKZ1Q/a/zIfep+Qc
SoH1zVszvA3e0J56F4LnTgEKuDgS94ZSUh9DHnZc2P1IACm14KyHWxWPHMYl9EzW
2JQiDnmwxP8keuQXu2wuiPtW+7XuFsXwr2LvgdelIubOExk8llV7jcTd4CgYjqsR
wEmyt2MR7c105sJ61X+Fcmj9ZsIw8e6BxwkYVGlkdadaOFeUv4bpeC4dhbLujHlf
jEAJy/qLpyZtC7fMgvSJalmnUUwZQYQoNYqqioSWUhcu/jg9BToCeoY1p3grl2Wv
CnKqCSe+bZqIM+R3JF9AHrdgT6PvfQ+hWbi5M1XRJmRYNRucFZxuzrhVbC7FpUsI
1/wo4oKofNtBKTy4BCafn52rXXfk8qrSZRmHKgBGteo6Aaxw8Nl9EUIxIUw4o9br
+8m9wroFXJA/t/O5Dmc/
=DIWf
-----END PGP SIGNATURE-----

--Apple-Mail=_165B12A1-5D1D-4E3C-B606-C317F013CCB4--
