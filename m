From: Olaf Hering <olaf@aepfle.de>
Subject: Re: [PATCH net-next v3 1/3] netvsc: transparent VF management
Date: Thu, 3 Aug 2017 16:19:37 +0200
Message-ID: <20170803141937.GF1646@aepfle.de>
References: <20170802025855.11521-1-sthemmin@microsoft.com>
 <20170802025855.11521-2-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="z0eOaCaDLjvTGF2l"
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.221]:25418 "EHLO
        mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751010AbdHCOTm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 10:19:42 -0400
Content-Disposition: inline
In-Reply-To: <20170802025855.11521-2-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--z0eOaCaDLjvTGF2l
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline

On Tue, Aug 01, Stephen Hemminger wrote:

>  static void netvsc_get_stats64(struct net_device *net,
>  			       struct rtnl_link_stats64 *t)
>  {
>  	struct net_device_context *ndev_ctx = netdev_priv(net);
>  	struct netvsc_device *nvdev = rcu_dereference_rtnl(ndev_ctx->nvdev);
> -	int i;
> +	struct netvsc_vf_pcpu_stats vf_tot;
> +		int i;

This move of 'i' was probably not intended.

Olaf

--z0eOaCaDLjvTGF2l
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iF0EARECAB0WIQSkRyP6Rn//f03pRUBdQqD6ppg2fgUCWYMw9QAKCRBdQqD6ppg2
fqkTAKDeKNgGJL8ilhWFZKW3/PeRn9W2dQCeL1qZ0BNaJIQPpZrRKH4/R5S45wU=
=TUUZ
-----END PGP SIGNATURE-----

--z0eOaCaDLjvTGF2l--
