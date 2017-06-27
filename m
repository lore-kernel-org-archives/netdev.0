From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [RFC 02/19] qed: Implement iWARP initialization, teardown and qp
 operations
Date: Tue, 27 Jun 2017 08:45:41 +0300
Message-ID: <20170627054541.GN1248@mtr-leonro.local>
References: <1498500429-22557-1-git-send-email-Michal.Kalderon@cavium.com>
 <1498500429-22557-3-git-send-email-Michal.Kalderon@cavium.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="hS2jB1L/urRucW8g"
Cc: ram.amrani@cavium.com, yuval.mintz@cavium.com,
        ariel.elior@cavium.com, davem@davemloft.net,
        netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        dledford@redhat.com
To: Michal Kalderon <Michal.Kalderon@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:42140 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751460AbdF0Fps (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 27 Jun 2017 01:45:48 -0400
Content-Disposition: inline
In-Reply-To: <1498500429-22557-3-git-send-email-Michal.Kalderon@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--hS2jB1L/urRucW8g
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Jun 26, 2017 at 09:06:52PM +0300, Michal Kalderon wrote:
> This patch adds iWARP support for flows that have common code
> between RoCE and iWARP, such as initialization, teardown and
> qp setup verbs: create, destroy, modify, query.
> It introduces the iWARP specific files qed_iwarp.[ch] and
> iwarp_common.h
>
> Signed-off-by: Michal Kalderon <Michal.Kalderon@cavium.com>
> Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
> Signed-off-by: Ariel Elior <Ariel.Elior@cavium.com>
>
> ---

<...>

> +#define QED_IWARP_PARAM_P2P		(1)

<...>

> +
> +	iwarp_info->peer2peer = QED_IWARP_PARAM_P2P;

Can you shed a light what is it?

Thanks

--hS2jB1L/urRucW8g
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAllR8QUACgkQ5GN7iDZy
WKcObhAArCKBQF92riKXZP+fj+HGUuEaf/DVBlnqLTNKki7FOgbRCgG1boe7oXxh
aNhFiSJDpe8ZwT6vsN7ZMozW2HNMBg5Cv2uenYMRnhycY1TrzFZmsr2itih9Y28c
eUQy90eSn14gbiCPB6iEidUw3qxIhtgmU9gXCyfr48VSiL1N+AI/g4Vx+oLERYrv
DfvKNr5IwI1aCAgf1l4UoC6gBGe4Gzg/3ztg1P2sw+hRWRKbiuikmdF2xpfz11jc
+AM6VJEAxNh13Q+Lk/im1h8CBqSAMic2jYbB6pk0PbMjNix8/asyo9Vq+VzYG+Sn
aYbcSMqBU71yV2+13tT/Q75s9xMz8Ca2Zxn6FC4+2zBSRyeOdW2orw6DEgW4rS8u
nqULFcUgUMKvxoqUvsU4aLnQbmsdkr73W7ciy1dRALKdD2VXFJ0rGEC5+za1URXo
RkmRpsP4gsfZWgac3VnHvJ++tkI9XZzqBHBPA1KbcoiQD+I63ahEjFDOL02TlBDV
AAlypvsFjXVy2EKgvKgcq4bWIAtwA/11iA6EVCuUqoIl0OJ1M9V6jaBgK6Uv/1iy
kOpnac5fogIILgnQeW1nDDfPlGPMIWWJoLoUE1GomO7TsW8fR8ENQjfziifK8KlM
guwsvea+dGkLjc0K3li5ButIyLYbhelHb8bNmoSGDt5Kf3vo+4A=
=PeyU
-----END PGP SIGNATURE-----

--hS2jB1L/urRucW8g--
