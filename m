From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH net-next 08/10] net/smc: introduce a delay
Date: Wed, 20 Sep 2017 17:03:15 +0300
Message-ID: <20170920140315.GR5788@mtr-leonro.local>
References: <20170920115813.63745-1-ubraun@linux.vnet.ibm.com>
 <20170920115813.63745-9-ubraun@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="pleSNuEbvnUYtMxG"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, linux-s390@vger.kernel.org,
        jwi@linux.vnet.ibm.com, schwidefsky@de.ibm.com,
        heiko.carstens@de.ibm.com, raspl@linux.vnet.ibm.com
To: Ursula Braun <ubraun@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:38366 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751391AbdITODT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 20 Sep 2017 10:03:19 -0400
Content-Disposition: inline
In-Reply-To: <20170920115813.63745-9-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--pleSNuEbvnUYtMxG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Sep 20, 2017 at 01:58:11PM +0200, Ursula Braun wrote:
> The number of outstanding work requests is limited. If all work
> requests are in use, tx processing is postponed to another scheduling
> of the tx worker. Switch to a delayed worker to have a gap for tx
> completion queue events before the next retry.
>

How will delay prevent and protect the resource exhausting?

Thanks

--pleSNuEbvnUYtMxG
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlnCdSMACgkQ5GN7iDZy
WKfCzw//SxhOvcLWVCJe3prP1yEVXO/bM4rUg/z0PscHUJC3y78FhWp7QUNTGQob
anKzUHXQVFaHD+LxtfNw78iLhQS37hzT2ZBOYmzj+iPuT/7Xlr7nJhqJll+YNwCF
k9HvIN1a/cEhjHMFQ+mTI7OUZDw0I7znqjlp+S4hh43OqPTt2KCXvWQP8XXCn5qU
2TbKJJK1hH7JKlM+wx0qr/vGnyV+/1SDEk4Onp+SXnLH7BrSl80nFEocKLLMMDz2
dbNE/rcjZD7Gv7zI5GLDiS4/FaX6ZzJAhaJHr4JgBTDZYxkt+mRi6jpiqQDGSrD+
z+b17gg3ehLvZKi7ZCLILGGoL7tfcRcQS9UUrHyMuBQmZQkrg1WsmeleptrKs1KS
ClNdIX3/QYBDBQamyFVaxGQG91t11+0YmwPTHoi88HbG1Ru+Ck9K1NKgr0WP0EPY
PmTXQ35j5bad9k9YqEjVhHd3nOwBc7Lvm6Pn55RzW/l5zS9ydeAousqCvkdDzVg6
QB9hcRTWT4Mr2YQTi7JJKEWxdCjolSXxLltwrK1GZrAVU2iTzD8IY3cgCrUyTWnH
iUXMRYgA1gBzu19i7oz97JhCx6HVcwLLgUWoMP4hnnghdNlCvJKyAQDzYIcfJtOm
IGHYgtLcb4aSYxPbgoR4WSQGFTdR2vg4DKNtyi1o68Fh6Kj5Gxg=
=jyO4
-----END PGP SIGNATURE-----

--pleSNuEbvnUYtMxG--
