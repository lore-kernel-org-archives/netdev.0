From: Phillip Susi <psusi@cfl.rr.com>
Subject: 802.3ad bonding brain damaged?
Date: Sun, 07 Aug 2011 15:52:22 -0400
Message-ID: <4E3EECF6.90409@cfl.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cdptpa-omtalb.mail.rr.com ([75.180.132.123]:50729 "EHLO
	cdptpa-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754756Ab1HGTwY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Aug 2011 15:52:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

- From Documentation/networking/bonding.txt:

	Additionally, the linux bonding 802.3ad implementation
	distributes traffic by peer (using an XOR of MAC addresses),

This is counter to the entire point of 802.3ad.  Distributing traffic by
hash of the destination address is poor mans load balancing for systems
not supporting 802.3ad.  When in 802.3ad mode, packets are supposed to
be queued to whichever interface has the shortest tx length so a single
stream to a single host can be balanced across all links instead of
being restricted to one, while the other is idle.
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk4+7PMACgkQJ4UciIs+XuKJtwCgrubCy9NgiS3HppxpRRtx4W7l
aFkAnR1uLW+4aM/TOSQgYZVsf/4yXGvE
=Yetx
-----END PGP SIGNATURE-----
