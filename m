From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [RFC 02/11] Add RoCE driver framework
Date: Tue, 13 Sep 2016 09:46:19 +0300
Message-ID: <20160913064618.GQ8812@leon.nu>
References: <1473696465-27986-1-git-send-email-Ram.Amrani@qlogic.com>
 <1473696465-27986-3-git-send-email-Ram.Amrani@qlogic.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="de1H0RjRxOSdb4we"
Cc: dledford@redhat.com, davem@davemloft.net, Yuval.Mintz@qlogic.com,
        Ariel.Elior@qlogic.com, Michal.Kalderon@qlogic.com,
        rajesh.borundia@qlogic.com, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org
To: Ram Amrani <Ram.Amrani@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:45270 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751389AbcIMGqY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Sep 2016 02:46:24 -0400
Content-Disposition: inline
In-Reply-To: <1473696465-27986-3-git-send-email-Ram.Amrani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--de1H0RjRxOSdb4we
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Sep 12, 2016 at 07:07:36PM +0300, Ram Amrani wrote:
> Adds a skeletal implementation of the qed* RoCE driver -
> basically the ability to communicate with the qede driver and
> receive notifications from it regarding various init/exit events.
>
> Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
> Signed-off-by: Ram Amrani <Ram.Amrani@qlogic.com>
> ---

<...>

> +
> +#define QEDR_MODULE_VERSION	"8.10.10.0"

I am strongly against module versions. You should rely on official
kernel version.

> +#define QEDR_NODE_DESC "QLogic 579xx RoCE HCA"
> +#define DP_NAME(dev) ((dev)->ibdev.name)

--de1H0RjRxOSdb4we
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX16C6AAoJEORje4g2clinDzAP/jxsNSAxKcogLHQEKCb4d0j7
RWTiP8bjTig7n/5zC14v0F8lHgB0Z1XZ/gFvKe2R2QUVP6wxsiy3nD+F9vR/W4BW
FTug0AloItJ2J+8dPlDZkz5w1hYvfktG0weqwIuIlkunavZneYbgo2wgn/0WhE4F
lGeKiX5n0OIgktM5R6FvegSJZ+lUNRrVi4TWTI/jkH57Db3ArlCnc3iArz2uf5ND
6G1DQ0hm2YWD1WIRlbJ26iVGyWirkLpcO/ggFka0cNVPtiQmPjQXqSjhrGvCwN5b
oCCjn/48ZvfRyYk9Z8vbkUiL+MxloXaczGLtNjc/H1uYEpbZW7iP70mv9ziRX5v7
mwgKgJsTgp2h5u7NVezUT9qgzItGERd/KYWmPjWL8An++IyyQeE7YR+Jy0fVBLRg
2SDIc78fdZUnvb1d++zrq1ZmZ93zBycQZLLH5s+Ep9av86jQgGTIt4//F7OHIC++
FRydRfH/ALG1L+YuZHuMYwqna7XlVP06Gi0UqXydMULon0FFHoZPc75d/ys+9izL
/tET/llpeIoo7sLwRvRwamWSURSXPSs6M3+gmUGSfDkNHOJoom+kWYqBp5fjYi/2
8sG81f4XHqeJr9P+Am9CM3dJ5zq7Dd0LqgjPbA9GSf/n+5jmDFECNnSjj7eW4Sce
R9qQm6+hEDRPRzYpfxy1
=7nRw
-----END PGP SIGNATURE-----

--de1H0RjRxOSdb4we--
