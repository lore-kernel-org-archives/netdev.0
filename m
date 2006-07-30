From: Hugo Santos <hsantos@av.it.pt>
Subject: Re: Regarding offloading IPv6 addrconf and ndisc
Date: Sun, 30 Jul 2006 12:30:50 +0100
Message-ID: <20060730113050.GL8334@innerghost.net>
References: <20060728014528.GB29313@innerghost.net> <20060727.192743.39159331.davem@davemloft.net> <20060728031322.GE29313@innerghost.net> <20060727.202044.85689055.davem@davemloft.net> <20060728033132.GF29313@innerghost.net> <20060727210738.36f33436@localhost.localdomain> <20060728083433.GG29313@innerghost.net> <1154090737.5165.69.camel@jzny2> <20060729133442.GI8334@innerghost.net> <44CC2741.4050706@miyazawa.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="dfmC41YZQlborXoK"
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	Stephen Hemminger <shemminger@osdl.org>,
	David Miller <davem@davemloft.net>,
	herbert@gondor.apana.org.au, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.av.it.pt ([193.136.92.53]:11190 "EHLO av.it.pt")
	by vger.kernel.org with ESMTP id S932267AbWG3Lax (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Jul 2006 07:30:53 -0400
To: Kazunori Miyazawa <kazunori@miyazawa.org>
Content-Disposition: inline
In-Reply-To: <44CC2741.4050706@miyazawa.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--dfmC41YZQlborXoK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

> On the other hand, if a ND daemon loose the synchronization, it is
> unpredicable, I guess.

   What do you mean by synchronization in this context? My idea was to
 keep the ND state machine inside the kernel, and instead have the
 daemon be reactive. That means it would send messages on behalf of the
 kernel, and apply information based on received signalling (besides, ND
 is reseliant to loss of messages). Taking your example, if the kernel
 is using a neighbor entry and you replace it (either changing it's
 state or link-layer address), the kernel will adapt, i believe it is
 predictable. To be honest, i'm only worried about possible lost netlink
 messages; but the daemon may be implemented to handle this, re-sending
 while an ACK isn't receiving, thus minimizing any de-synchronization
 possibilities.

> BTW, we have a choice which we implement a functionality as a
> module. I think it can achieve some of what you want.

   Well, exporting the functionality to a module would be a start to
 have one moving it out of the kernel. :-)

   Hugo

--dfmC41YZQlborXoK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFEzJhq7asb/itUNKwRAsxoAJ0Xnj0w2IRGwj9w4vi4gINTE02ROACgtiJD
5eCY//iIDBWf7wWcyOwcfDA=
=PuL7
-----END PGP SIGNATURE-----

--dfmC41YZQlborXoK--
