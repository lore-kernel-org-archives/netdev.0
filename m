From: Alexander Zimmermann <alexander.zimmermann@comsys.rwth-aachen.de>
Subject: Re: TCP new-reno support?
Date: Tue, 21 Jun 2011 18:32:02 +0200
Message-ID: <A6200100-A147-481C-8230-9782822EA1F7@comsys.rwth-aachen.de>
References: <4E00BDAB.1040309@candelatech.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg=pgp-sha1; boundary=Apple-Mail-7--345759329
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:39870 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756945Ab1FUQcE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 12:32:04 -0400
Received: from ironport-out-2.rz.rwth-aachen.de ([134.130.5.41])
 by mta-1.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0LN5005KYF9FGBI0@mta-1.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Tue, 21 Jun 2011 18:32:03 +0200 (CEST)
Received: from [IPv6:::1] ([unknown] [137.226.54.2])
 by relay-auth-1.ms.rz.rwth-aachen.de
 (Sun Java(tm) System Messaging Server 7.0-3.01 64bit (built Dec  9 2008))
 with ESMTPA id <0LN500AWCF9ERL20@relay-auth-1.ms.rz.rwth-aachen.de> for
 netdev@vger.kernel.org; Tue, 21 Jun 2011 18:32:03 +0200 (CEST)
In-reply-to: <4E00BDAB.1040309@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--Apple-Mail-7--345759329
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=us-ascii

Hi,

Am 21.06.2011 um 17:50 schrieb Ben Greear:

> I see a large number of TCP congestion algorithms supported, but
> nothing that explicitly says newreno.

It's implicit :-)

>  Is it actually supported?

tcp_congestion_control=reno
tcp_dsack=0 
tcp_fack=0 
tcp_sack=0
tcp_frto=0

then, you get NewReno. And, yes, it's not possible to get Reno

Alex

> 
> Thanks,
> Ben
> 
> -- 
> Ben Greear <greearb@candelatech.com>
> Candela Technologies Inc  http://www.candelatech.com
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

//
// Dipl.-Inform. Alexander Zimmermann
// Department of Computer Science, Informatik 4
// RWTH Aachen University
// Ahornstr. 55, 52056 Aachen, Germany
// phone: (49-241) 80-21422, fax: (49-241) 80-22222
// email: zimmermann@cs.rwth-aachen.de
// web: http://www.umic-mesh.net
//


--Apple-Mail-7--345759329
content-type: application/pgp-signature; x-mac-type=70674453;
	name=PGP.sig
content-description: Signierter Teil der Nachricht
content-disposition: inline; filename=PGP.sig
content-transfer-encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.17 (Darwin)
Comment: GPGTools - http://gpgtools.org

iEYEARECAAYFAk4Ax4IACgkQdyiq39b9uS5kugCeJNLSnylfwUGTQIQIGQWIhGex
4iIAmgJojHSLJcbRXpLNfL4SBuy/XawX
=1y0Q
-----END PGP SIGNATURE-----

--Apple-Mail-7--345759329--
