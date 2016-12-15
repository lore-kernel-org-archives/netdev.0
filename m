From: Doug Ledford <dledford@redhat.com>
Subject: Re: [RFC v2 00/10] HFI Virtual Network Interface Controller (VNIC)
Date: Thu, 15 Dec 2016 13:19:18 -0500
Message-ID: <4e22bf29-2260-0768-ab17-9a8df6306f37@redhat.com>
References: <1481788782-89964-1-git-send-email-niranjana.vishwanathapura@intel.com>
 <20161215091226.GC811@mtr-leonro.local>
 <20161215145212.GA29116@phlsvsds.ph.intel.com>
 <380b05bf-a18e-1f20-7e8e-10b61f77dec7@redhat.com>
 <20161215170713.GD3264@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="xAMPl5jDJBWlK3FQp4N5f5QscxMK1Smh4"
Cc: "ira.weiny" <ira.weiny@intel.com>,
        Leon Romanovsky <leon@kernel.org>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        "David S. Miller" <davem@davemloft.net>,
        "Vishwanathapura, Niranjana" <niranjana.vishwanathapura@intel.com>,
        linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        dennis.dalessandro@intel.com
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50898 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753819AbcLOSTy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Dec 2016 13:19:54 -0500
In-Reply-To: <20161215170713.GD3264@obsidianresearch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--xAMPl5jDJBWlK3FQp4N5f5QscxMK1Smh4
Content-Type: multipart/mixed; boundary="7f3fhwpxcNLGMW5MXnvUbHmtRsV4f0tt0";
 protected-headers="v1"
From: Doug Ledford <dledford@redhat.com>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: "ira.weiny" <ira.weiny@intel.com>, Leon Romanovsky <leon@kernel.org>,
 Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
 "David S. Miller" <davem@davemloft.net>,
 "Vishwanathapura, Niranjana" <niranjana.vishwanathapura@intel.com>,
 linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
 dennis.dalessandro@intel.com
Message-ID: <4e22bf29-2260-0768-ab17-9a8df6306f37@redhat.com>
Subject: Re: [RFC v2 00/10] HFI Virtual Network Interface Controller (VNIC)
References: <1481788782-89964-1-git-send-email-niranjana.vishwanathapura@intel.com>
 <20161215091226.GC811@mtr-leonro.local>
 <20161215145212.GA29116@phlsvsds.ph.intel.com>
 <380b05bf-a18e-1f20-7e8e-10b61f77dec7@redhat.com>
 <20161215170713.GD3264@obsidianresearch.com>
In-Reply-To: <20161215170713.GD3264@obsidianresearch.com>

--7f3fhwpxcNLGMW5MXnvUbHmtRsV4f0tt0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 12/15/2016 12:07 PM, Jason Gunthorpe wrote:
> On Thu, Dec 15, 2016 at 11:28:06AM -0500, Doug Ledford wrote:
>=20
>> 1) Since your intent is to make this work with multiple versions of th=
e
>> hfi drivers, I disagree with Jason that just because there is only one=

>> driver today that we should keep it simple.  Design it right from the
>> beginning of multi driver is your intent is, IMO, a better way to go.
>> You'll work out the bugs in the initial implementation and when it com=
es
>> time to add the second driver, things will go much more smoothly.
>=20
> If that is your position then this should be a straight up IB ULP that
> works with any IB hardware.

Yes, see my comments in point #3 of my previous email...

> There is nothing HFI specific about it except for the
> micro-optimization of pushing packets via SDMA instead of post_send,
> and that same micro optimization probably applies to ipoib.
>=20
> In other words, lets see the first version as a straight ULP with no
> special HFI hooks, then we can discuss how best to micro optimize it
> for HFI SDMA.
>=20
> Jason
>=20


--=20
Doug Ledford <dledford@redhat.com>
    GPG Key ID: 0E572FDD


--7f3fhwpxcNLGMW5MXnvUbHmtRsV4f0tt0--

--xAMPl5jDJBWlK3FQp4N5f5QscxMK1Smh4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJYUt6mAAoJELgmozMOVy/dDYEP/3GykcLCvyjCy4f0bmNQAkpe
Ld4ncBEdvCNHozf+LTmU/FJ55Vas7lxONdN7TaystgxUiB/9E7uY9to0x9iVH+SM
93kbmi4OmRUVqEsAJqtihtCHJ+IsuzTGBQROEEwZrxP8bnXWblbGEBaI1Th9hw7K
mqYVgZgDLAtoNUhHEru0fbO/SN3k3+NHfh0N7xPuqhWZnx2+jhdmYLnO4sGbRijn
P5HVU+cdVkdey9AzJFxcIPHz8Wy4JFkOBJgYd3OauEvEv7XAVLxNUiNpvnYYz2hw
BfjL0kWU7QCFqVkVJb57A8C9LrXtCNHqG7lPbO1HzuazJX7CpCs9njxfICc8+htV
TXonQcM9stqn4HeBrf4nZPDOBU8b73N5IlginCMSUoRgELX2fWgLKzooefA7JEGr
rxe1AgGBnUP1E08fralDc7D7VhxyjJj4s70Vs95ve4PQ0q/a7X4K7d/lIzy+ajmf
kGzLIP6yGn/JX+HMCg57T7z3eu4c567ZDuVWze7f94eugwA8YokRk/a3ozl3xV8d
ZPmVcVTjn4AIL3HzJCswazwv8rY75ZPKb+L4PRnBIfEprWtizoBL9EndIeYsGkmw
zVEMhH+224oSaj8o+JdHIMBEpTpVV4R8gECZ3OlyQbjjEQXQoDOhonFsL/U26Egn
UoyGyU2mHN5eHh+j5tKH
=EcLi
-----END PGP SIGNATURE-----

--xAMPl5jDJBWlK3FQp4N5f5QscxMK1Smh4--
