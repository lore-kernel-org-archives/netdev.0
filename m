From: Doug Ledford <dledford@redhat.com>
Subject: Re: [PATCH] IB/ipoib: move back the IB LL address into the hard
 header
Date: Wed, 12 Oct 2016 14:21:46 -0400
Message-ID: <4779d199-4515-ee06-af0f-69e1d1b86b86@redhat.com>
References: <1dbd83dfe7f435eecc5bc460e901b47758280f30.1476206016.git.pabeni@redhat.com>
 <20161011173216.GA16892@obsidianresearch.com>
 <22f61258-9bcf-0adc-f23f-79a4f1d50c6a@redhat.com>
 <20161011180119.GB17319@obsidianresearch.com>
 <1476209407.448.9.camel@redhat.com>
 <073e0007-a43b-134d-ba7e-b290304be585@redhat.com>
 <20161011183019.GC20253@obsidianresearch.com>
 <9bed7085-949b-c68b-91ed-f930702a6a94@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="IAmVhdT75FG2B94rwtsEAu9BUF5L6OI6G"
Cc: Paolo Abeni <pabeni@redhat.com>, linux-rdma@vger.kernel.org,
        Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        netdev@vger.kernel.org
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42684 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932868AbcJLSWC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Oct 2016 14:22:02 -0400
In-Reply-To: <9bed7085-949b-c68b-91ed-f930702a6a94@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--IAmVhdT75FG2B94rwtsEAu9BUF5L6OI6G
Content-Type: multipart/mixed; boundary="ohePGETKNmv91mOwiBIJ5lxsD9ltNDiwJ";
 protected-headers="v1"
From: Doug Ledford <dledford@redhat.com>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: Paolo Abeni <pabeni@redhat.com>, linux-rdma@vger.kernel.org,
 Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock
 <hal.rosenstock@gmail.com>, netdev@vger.kernel.org
Message-ID: <4779d199-4515-ee06-af0f-69e1d1b86b86@redhat.com>
Subject: Re: [PATCH] IB/ipoib: move back the IB LL address into the hard
 header
References: <1dbd83dfe7f435eecc5bc460e901b47758280f30.1476206016.git.pabeni@redhat.com>
 <20161011173216.GA16892@obsidianresearch.com>
 <22f61258-9bcf-0adc-f23f-79a4f1d50c6a@redhat.com>
 <20161011180119.GB17319@obsidianresearch.com>
 <1476209407.448.9.camel@redhat.com>
 <073e0007-a43b-134d-ba7e-b290304be585@redhat.com>
 <20161011183019.GC20253@obsidianresearch.com>
 <9bed7085-949b-c68b-91ed-f930702a6a94@redhat.com>
In-Reply-To: <9bed7085-949b-c68b-91ed-f930702a6a94@redhat.com>

--ohePGETKNmv91mOwiBIJ5lxsD9ltNDiwJ
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 10/11/2016 2:50 PM, Doug Ledford wrote:
> On 10/11/2016 2:30 PM, Jason Gunthorpe wrote:
>> On Tue, Oct 11, 2016 at 02:17:51PM -0400, Doug Ledford wrote:
>>
>>> Well, not exactly.  Even if we put 65520 into the scripts, the kernel=

>>> will silently drop it down to 65504.  It actually won't require anyon=
e
>>> change anything, they just won't get the full value.  I experimented
>>> with this in the past for other reasons and an overly large MTU setti=
ng
>>> just resulted in the max MTU.  I don't know if that's changed, but if=
 it
>>> still works that way, this is much less of an issue than it might
>>> otherwise be.
>>
>> So it is just docs and relying on PMTU? That is not as bad..
>>
>> Still would be nice to avoid if at all possible..
>=20
> I agree, but we have a test getting ready to commence.  We'll know
> shortly how much the reduced MTU effects things because they aren't
> going to alter any of their setup, just put the new kernel in place, an=
d
> see what happens.
>=20
>=20

Long story short on the MTU stuff, the setups whined a bit about not
being able to set the desired MTU, used the new max MTU instead, and
things otherwise worked fine.  But, Paolo submitted a v2 patch that
removes this change, so it's all moot anyway.

--=20
Doug Ledford <dledford@redhat.com>
    GPG Key ID: 0E572FDD


--ohePGETKNmv91mOwiBIJ5lxsD9ltNDiwJ--

--IAmVhdT75FG2B94rwtsEAu9BUF5L6OI6G
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJX/n86AAoJELgmozMOVy/dHbkQAKsGv79P83AHzQZNVYqsErOy
lMVPVe0CKnfgxmko1UioWhxNVWdp0tPuWQhD40nP3PWegZ786gGuNXEUQxQeZ69W
3P0EkD+JNQfmBA+rugyogPQCsHwjZ2AFeoMaQNMF+oswEPdUy5xp3EKZM2ztQNO6
B/wedPSDq3cmCW0NH5N0AItczUftljgDIMBziRhddoPUX+3Wu3cAE9W7bFwQFnvg
NA1uHWG7j8VPhualbXEAkZVGbimq58F8ZA2SAoIc+xwe8KiQufl6zdl3GeD9Bt9o
AfmqUZ+hFGSEG1NiL4iuRPVTGyEAFZo1vFsqC9H385farnxYL/YHqCwzcsChxeNw
x/FtPw1dPbFwb+uKzh03MZmTlJopriWHojBXernIvUnEabeXRD2qGWzrFWIr5JIa
p+p2zlRA35lgXQyGQPSKtQWSMjvfNesVG0Ly97IVzSe82nTwzNoINfK/XDWGey+a
VztDw3Jn7Ju1/Nx/3YTmktjVLhXCpwg+8FdRakMuMqqRnzoNmdNVugL5VugU7V4K
YmBhGU9c7vxbG5mMT1Yd17tvZ5qWDpViuwtli28MCYFlCD5Dh0HJwh7VdCpFU6Iy
nHkAG/1nta5AjXN5z/ouJs5kMF5vQlLpU5rqWD77s+Y9TChsMraL1yTpEqFKtYcN
/+/lYrHtf7HDROYzcu1h
=pZLb
-----END PGP SIGNATURE-----

--IAmVhdT75FG2B94rwtsEAu9BUF5L6OI6G--
