From: Leon Romanovsky <leonro@mellanox.com>
Subject: Re: [pull request][for-next 00/12] Mellanox, mlx5 IPoIB Muli Pkey
 support 2017-10-11
Date: Sun, 15 Oct 2017 09:30:12 +0300
Message-ID: <20171015063012.GW2106@mtr-leonro.local>
References: <20171014184827.18491-1-saeedm@mellanox.com>
 <af28440c-bb1c-c47b-92dd-60bfbeaa839d@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="PoKbPPFu8MuDl6RC"
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org
To: Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0089.outbound.protection.outlook.com ([104.47.0.89]:11072
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750704AbdJOGaU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 15 Oct 2017 02:30:20 -0400
Content-Disposition: inline
In-Reply-To: <af28440c-bb1c-c47b-92dd-60bfbeaa839d@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--PoKbPPFu8MuDl6RC
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sat, Oct 14, 2017 at 05:19:34PM -0400, Doug Ledford wrote:
> On 10/14/2017 2:48 PM, Saeed Mahameed wrote:
> > Hi Dave and Doug,
> >
> > This series includes updates for mlx5 IPoIB offloading driver from Alex
> > and Feras to add the support for Muli Pkey in the mlx5i ipoib offloading netdev,
> > to be merged into net-next and rdma-next trees.
>
> As far as the two IPoIB patches are concerned, they're fine.
>
> > Doug, I am sorry I couldn't base this on rc2 since the series needs and conflicts
> > with a fix that was submitted to rc3, so to keep things simple I based it on rc4,
> > I hope this is ok with you..
>
> No worries, it just means I have to submit it under another branch.  But
> I'm already holding one patch series in a stand alone branch, so no big
> deal.  And, actually, the IPoIB changes are so small they can simply go
> through Dave's tree if you don't have any dependent code in the IPoIB
> driver to submit after this but still in this devel cycle.

I have IPoIB NAPI implementation waiting for this shared code.

Thanks

>
> > Please pull and let me know if there's any problem.
>
> Once I hear that Dave is OK with the net changes, I'm ready to pull (if
> I need to).
>
> --
> Doug Ledford <dledford@redhat.com>
>     GPG Key ID: B826A3330E572FDD
>     Key fingerprint = AE6B 1BDA 122B 23B4 265B  1274 B826 A333 0E57 2FDD
>




--PoKbPPFu8MuDl6RC
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlnjAHQACgkQ5GN7iDZy
WKcgkxAAn+cHgtFq6GlaWX4eost0Kq/KIxuvmvfkRR9/86rTqTA1RJ/355aCT8KE
VGsq3K811ZnCnfeXOiA+HhmHPiwc6AVqOzH4F5g2CKYFkX7lKMyv7HgBa4hiWS5Y
alDa1/BkiAH3kLpte1jKgk2xejVGo7+Qr5CzCLp/I6QmIyOlAAX89THC4HrcPhbk
gKCN59ZMfVh2rgwPRqUaZfFCNjAThROkchuB9bOW3teiRZO9tOy4BSOFnwr6rQMG
8OBP3y0MxSMmhnFskDhxLkhGhFebXOhP4z+GBQpu6mthb61GS5DhKACstqG245g/
H6Ii6hjyF8B+rCk7cyonk+lC8Bk538xqcyCi8Kp6+YKYNX/1RTCUOEHkIWVVeMUG
Lc/Nh0SL6KcwP0S+jVpY+Nn1hkDCBl5SkfCeDkW9wHc+lqY+KHN/AuRR9ZPwW9lU
dYWzjBao8hrtqYVJbg55qZjF58ogsv57CQ8hHdGOak9j+gXvQrJ7I/wxD/31IN9E
iitCN8j41vdZs5Klf3WqlwuUBSAJDEgAlSAVmMqndhDFH2hrW1RvJvELIUp15/XW
wdslTY+wMMyIbwrO6o9WjTPP9KK90fFuR5b6HSW8tEWF9qJkC7At2NNGYF6Rh0Yt
A4KhmLOuEpu7OMpg9pBQyT+ADuAEKDpt/StvY+HdXmMlahK9FXY=
=nAVk
-----END PGP SIGNATURE-----

--PoKbPPFu8MuDl6RC--
