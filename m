From: Mark Rustad <mrustad@gmail.com>
Subject: Re: [Intel-wired-lan] [PATCH] igb: add more checks for disconnected
 adapter
Date: Mon, 21 Sep 2015 22:03:42 -0700
Message-ID: <5600E12E.4040005@gmail.com>
References: <1442855488-27453-1-git-send-email-jarod@redhat.com>
 <56007D34.1070306@gmail.com> <5600D5A2.70403@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="VSXMPKu0CqtWuKohuibtTjfsmrohdsX9o"
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org
To: Jarod Wilson <jarod@redhat.com>,
	Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5600D5A2.70403@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--VSXMPKu0CqtWuKohuibtTjfsmrohdsX9o
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 9/21/15 9:14 PM, Jarod Wilson wrote:
> Just switching to adapter->io_addr everywhere seems to not work as=20
> noted above. :\ Note that I'm also chasing this from the other end=20
> with the author of the pci patches that seem to have triggered this,=20
> so the real bug might be over in pci-land, but hardening against=20
> explosions in igb still seems like a worthwhile effort here.

My understanding is that there can be problems if too many writes to a
removed device happen. That is why ixgbe avoids doing that by testing
for removal in some places. The io_addr does get used in the transmit
path simply to avoid adding a test to that hot path. That approach
seems to be working well for ixgbe.


--VSXMPKu0CqtWuKohuibtTjfsmrohdsX9o
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCAAGBQJWAOEuAAoJEDwO/+eO4+5u5csP/A+fytBtmTHjUYSdwLCL1e9H
G+qk8eLL2EGzcc0eXy6sMLLyPFQmrif6lcmQE3jZXGUMTn2/wArlPII0cw+cWgHp
xa25f9sjChHgPKRjNe6VyAjICnK7N0DTc/VdpVbDSqoNaA0R+8c2MvjGb+/7+vfs
ZLB6y8pGQG+fjUMxLtfrTrMuUWGmW5UexLWS4pG7Xxz1VI8FwPzEWdgNUHC5bdBv
Uyz4hvSSoxwLo/2F6z6FFaMoJ2N6fW/Br1FkeOM54BSN8KAnEU9/kiOk7Xb79Ttd
pXLo5UQajEEDO7Rf0vTOBCeMYk3U/f/AlVD4LsFK2EASncbmfYhRoLKnvv98L/W6
PiGBbAXWH6hwbvbZD9ry65sl1DONrZlK+0gI/acCJ7r7DbmAniw1xHoYqs8YpjlY
2SrRozmupmILn1dB2bwjzu231O0pEgvpPXUXxcm/R6a/4CYzN1uPkNZtK6RzZf6j
Ia07A9QicUD/qP/50xvo+cHPqDNL4a+cdIyAls7G1eD3AVBbq+m87r5CR42e77AX
CiPSe7sNRcG2UTfdgAfT/WVSl1OuVVLgf43Pqu8UhoCBqYRhXuMmLxeV3E/YCm+0
dEbXjpsDT+ovfgzEYl43ilGTOMHnpO/QN+NOLgnkIjaLOcKx2eNJw6MQHor8szqG
xAkks+6pvQKPsVbaPvUr
=lt7y
-----END PGP SIGNATURE-----

--VSXMPKu0CqtWuKohuibtTjfsmrohdsX9o--
