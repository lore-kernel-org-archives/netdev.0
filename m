From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH net] netem: fix loss generators
Date: Wed, 27 Nov 2013 22:28:50 +0100
Message-ID: <20131127212849.GA1428@virgo.local>
References: <20131121175419.59059598@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="PEIAKu/WMn1b1Hv9"
Cc: David Miller <davem@davemloft.net>, stefano.salsano@uniroma2.it,
	netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:36551 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755867Ab3K0V24 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Nov 2013 16:28:56 -0500
Content-Disposition: inline
In-Reply-To: <20131121175419.59059598@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--PEIAKu/WMn1b1Hv9
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

* Stephen Hemminger | 2013-11-21 17:54:19 [-0800]:

>Patch from developers of the alternative loss models, downloaded from:
>   http://netgroup.uniroma2.it/twiki/bin/view.cgi/Main/NetemCLG
>
>We found some bugs in our first implementation.
>A first set of bugs is in the function loss_4state:
>   In the case 1 of the switch statement in the if conditions we
>    need to add clg->a4 to clg->a1, according to the model.
>   In the case 3 of the switch statement we need to delete "return
>    true" if the condition leads us in the state 1, because the state 1 is
>    a good state.

I already fixed the former bug[1]. I cc'ed stefano.salsano@uniroma2.it but did
not get any acked-by/tested-by. The second bug still exists.

Hagen

[1] http://www.spinics.net/lists/netdev/msg255165.html

--PEIAKu/WMn1b1Hv9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iEYEARECAAYFAlKWZBEACgkQSiKNRZg1DCK3rwCg+oi9QVAx2L+4+VH6l1BCPH2d
7GoAnRI1/82X3IxEiMa+aC36/sPceNCy
=dZ+F
-----END PGP SIGNATURE-----

--PEIAKu/WMn1b1Hv9--
