From: Alexander Zimmermann <alexander.zimmermann@comsys.rwth-aachen.de>
Subject: Re: [PATCH] tcp: Expose the initial RTO via a new sysctl.
Date: Tue, 17 May 2011 10:01:31 +0200
Message-ID: <E5F8880D-72DF-488B-9515-60453D3EC240@comsys.rwth-aachen.de>
References: <1305618020-72535-1-git-send-email-tsunanet@gmail.com>
 <1305618020-72535-2-git-send-email-tsunanet@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg=pgp-sha1; boundary=Apple-Mail-1-894577629
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Benoit Sigoure <tsunanet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:55478 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752730Ab1EQIBf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 04:01:35 -0400
In-reply-to: <1305618020-72535-2-git-send-email-tsunanet@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--Apple-Mail-1-894577629
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=us-ascii

Hi Benoit,

Am 17.05.2011 um 09:40 schrieb Benoit Sigoure:

> Instead of hardcoding the initial RTO to 3s and requiring
> the kernel to be recompiled to change it, expose it as a
> sysctl that can be tuned at runtime.  Leave the default
> value unchanged.
> 

regardless of netdev will accept this patch or not, the
upcoming initRTO is 1s. See
http://tools.ietf.org/id/draft-paxson-tcpm-rfc2988bis-02.txt

The draft is IESG approved and will become an RFC soon.

Alex

//
// Dipl.-Inform. Alexander Zimmermann
// Department of Computer Science, Informatik 4
// RWTH Aachen University
// Ahornstr. 55, 52056 Aachen, Germany
// phone: (49-241) 80-21422, fax: (49-241) 80-22222
// email: zimmermann@cs.rwth-aachen.de
// web: http://www.umic-mesh.net
//


--Apple-Mail-1-894577629
content-type: application/pgp-signature; x-mac-type=70674453;
	name=PGP.sig
content-description: Signierter Teil der Nachricht
content-disposition: inline; filename=PGP.sig
content-transfer-encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.17 (Darwin)
Comment: GPGTools - http://gpgtools.org

iEYEARECAAYFAk3SK1wACgkQdyiq39b9uS73UACfQn3YrE8XnWhfHD2+/K1q3lsJ
sfYAoISLXJEz5i0xMXGVAd+TMz8Hn6eT
=pW+T
-----END PGP SIGNATURE-----

--Apple-Mail-1-894577629--
