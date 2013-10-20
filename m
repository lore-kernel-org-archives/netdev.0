From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH iproute2] ss: make socket statistic parseable
Date: Sun, 20 Oct 2013 15:24:27 +0200
Message-ID: <20131020132427.GA4514@virgo.local>
References: <1382205252-14988-1-git-send-email-hagen@jauu.net>
 <1382219776.3284.49.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="LQksG6bCIzRHxTLp"
Cc: netdev@vger.kernel.org, shemminger@vyatta.com,
	Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:57890 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751023Ab3JTNYb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Oct 2013 09:24:31 -0400
Content-Disposition: inline
In-Reply-To: <1382219776.3284.49.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--LQksG6bCIzRHxTLp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

* Eric Dumazet | 2013-10-19 14:56:16 [-0700]:

>Seems fine to me, maybe we want to support json for better parsing
>capabilities ?

Currently the parsing is straight forward with Python: split for
whitespaces and subsequent split for colon to get a key/value list. Supporting
an additional format may be overhead - not sure?! But yeah, JSON formated
output is nice too. The current format has the advantage that it is human
readable and "good" machine parseable. Except the first line:

tcp    ESTAB      0      0 192.168.1.29:58951 208.68.163.218:xmpp-cli

The line has a strict order, so it is not that hard to write a correct parser.


Btw: for people not following google plus circus: I wrote an parser for ss(8)
for plotting TCP stack variables:

http://research.protocollabs.com/captcp/doc-socket-statistic-module.html


Cheers, Hagen

--LQksG6bCIzRHxTLp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iEYEARECAAYFAlJj2YsACgkQSiKNRZg1DCIa9ACgg3s90kTZBMtzFgkUDituP/xT
8ZkAoJBM3rDaJavtcnD6mBy31nZNqrfq
=aRbm
-----END PGP SIGNATURE-----

--LQksG6bCIzRHxTLp--
