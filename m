From: Hugo Santos <hsantos@av.it.pt>
Subject: Re: Regarding offloading IPv6 addrconf and ndisc
Date: Tue, 1 Aug 2006 13:13:01 +0100
Message-ID: <20060801121301.GZ8334@innerghost.net>
References: <E1G6Fic-0005py-00@gondolin.me.apana.org.au> <20060727.183415.104032934.davem@davemloft.net> <200608010231.58339.ak@suse.de> <20060731.174641.99457765.davem@davemloft.net> <ada7j1t700x.fsf@cisco.com> <1154395467.5170.31.camel@jzny2> <20060801013033.GA1280@gondor.apana.org.au> <1154396860.5170.51.camel@jzny2>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="abYdCjSRCBwcb+dP"
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	ak@suse.de, David Miller <davem@davemloft.net>,
	Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.av.it.pt ([193.136.92.53]:20952 "EHLO av.it.pt")
	by vger.kernel.org with ESMTP id S1751263AbWHAMNC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 08:13:02 -0400
To: Jamal Hadi Salim <hadi@znyx.com>
Content-Disposition: inline
In-Reply-To: <1154396860.5170.51.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--abYdCjSRCBwcb+dP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Jamal,

> nice to know ;-> At least you can protect some apps if you need to.
> Only racoon and quagga are important for me.
> But what happens then if you have a beast that just chews memory
> forever? I suppose other poor apps will just get shot.

   You should push QoS and differentiation into the memory-subsystem :-)
 Give a priority flag to mmap(). It's not simple to degrade existing
 allocations, but taking into consideration the OOM killer...

   Hugo

--abYdCjSRCBwcb+dP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFEz0VN7asb/itUNKwRAl0jAJ9/ja/DUGO+sqOjB/99qQKrT8t2OQCg5B1M
6Ef3Bzeo751KXCgdXkHRKzM=
=zNQs
-----END PGP SIGNATURE-----

--abYdCjSRCBwcb+dP--
