From: Volker Lendecke <Volker.Lendecke@SerNet.DE>
Subject: Re: Splice on blocking TCP sockets again..
Date: Wed, 30 Sep 2009 08:37:13 +0200
Message-ID: <E1Mssmb-004RJz-Hf@intern.SerNet.DE>
References: <20090930004820.GC19540@obsidianresearch.com>
Reply-To: Volker.Lendecke@SerNet.DE
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="pf9I7BMVVzbSWLtt"
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Volker Lendecke <vl@samba.org>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.SerNet.de ([193.175.80.2]:38591 "EHLO mail.SerNet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751987AbZI3HNn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2009 03:13:43 -0400
Content-Disposition: inline
In-Reply-To: <20090930004820.GC19540@obsidianresearch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--pf9I7BMVVzbSWLtt
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Sep 29, 2009 at 06:48:20PM -0600, Jason Gunthorpe wrote:
> FWIW, it looks like samba has a splice code now, but doesn't enable it
> due to this issue?

Right. What I've learned from the comments is that splice is
only usable in multi-threaded programs. One thread is
reading, one is writing from the other end. I deferred using
splice until we have the proper architecture to do sync
syscalls in helper threads to make them virtually async.  We
have some code for that now, but it's not a high priority
for me at this moment.

Volker

--pf9I7BMVVzbSWLtt
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkrC/JgACgkQbsgDfmnSbrZKbACfXnCw+X/usr+pTpIfRsEZ5iGO
r9cAoJNrws2FEwcPrxsQCLmqvWrn/zBJ
=eolt
-----END PGP SIGNATURE-----

--pf9I7BMVVzbSWLtt--
