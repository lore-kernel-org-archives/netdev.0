From: Andrey Rahmatullin <wrar@altlinux.org>
Subject: Re: via_rhine kernel crashes in 2.6.32
Date: Tue, 22 Dec 2009 20:00:45 +0500
Message-ID: <20091222150045.GA5355@wrars-comp.wrarsdomain>
References: <alpine.DEB.2.01.0912211040100.3483@bogon.housecafe.de>
 <20091222123211.GA8546@ff.dom.local>
 <20091222132107.GA9060@ff.dom.local>
 <20091222133817.GA9208@ff.dom.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="x+6KMIRAuhnl3hBn"
Cc: Christian Kujau <lists@nerdbynature.de>,
	LKML <linux-kernel@vger.kernel.org>,
	Roger Luethi <rl@hellgate.ch>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from k66.ru ([87.224.128.21]:55017 "EHLO k66.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752043AbZLVPAt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Dec 2009 10:00:49 -0500
Content-Disposition: inline
In-Reply-To: <20091222133817.GA9208@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--x+6KMIRAuhnl3hBn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Dec 22, 2009 at 01:38:17PM +0000, Jarek Poplawski wrote:
> > > It looks like napi_disable() should be illegal in ndo_tx_timeout().
> > > Here is a patch which moves most of the timeout work to a workqueue,
> > > similarly to tg3 etc. It should prevent at least one of reported
> > > bugs. Alas I can't even check-compile it at the moment, so let me
> > > know on any problems.
> > It seems I needlessly changed locking btw, so here it is again.
> Hmm... On the other hand, it definitely needs at least _bh now...
I've tried this patch. There are lots of "Transmit timed out", but no
crashes.

--=20
WBR, wRAR (ALT Linux Team)

--x+6KMIRAuhnl3hBn
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBCAAGBQJLMN8dAAoJEOih81koZvPBXWsH/3GW7Zv6RDRLKyxr1DOgCXQP
9Wpgs+7hd40xhTuSAYgoXPf/7MCIlhOcooCQP7EDLSEWrLGqhO2I+gKcXRVJLrlh
ohY9vI3xDQMFXHlo16h9qiwYZ2JXG53jBftdQacjvhIJuMB1N4Y4uRIhrLG2Ri9M
YqyNH59gqGEULrYnAzDJkqpi4wxx9N10cz/tPjYv1FssjIZZ4AaFgqC4ZitzQU1E
EZRrWhI8ITOU2XEcyqe2g9URwNs0YOG+qw0l+z2FLqB1qqix1KparMruInikJiBS
RYHTfWGd5MYsck672LWrDzX899Ln9kwU5YGtQAJ3UEL7LAtxBd7V90eBhwNJnQo=
=zAut
-----END PGP SIGNATURE-----

--x+6KMIRAuhnl3hBn--
