From: Kevin Winchester <kjwinchester@gmail.com>
Subject: Re: 2.6.24-rc2-mm1 -- strange apparent network failures
Date: Sat, 17 Nov 2007 21:17:12 -0400
Message-ID: <473F9298.7060401@gmail.com>
References: <20071113175906.497a1a6a.akpm@linux-foundation.org> <20071115164441.67a8e2df.akpm@linux-foundation.org> <473E794A.4060107@kernel.org> <200711170848.35726.kjwinchester@gmail.com> <473F7EDB.60701@kernel.org> <473F8C46.4070308@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, apw@shadowen.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kamalesh@linux.vnet.ibm.com
To: Andrew Morgan <morgan@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from simmts6-srv.bellnexxia.net ([206.47.199.164]:61326 "EHLO
	simmts6-srv.bellnexxia.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754288AbXKRBRP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Nov 2007 20:17:15 -0500
In-Reply-To: <473F8C46.4070308@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Kevin Winchester wrote:
> Looking at the code being bypassed:
> 
>     if (pE.cap[i] || pP.cap[i] || pP.cap[i])
> 
> looks somewhat weird as it is testing the same condition twice.  Should
> it have been:
> 
>     if (pE.cap[i] || pP.cap[i] || pI.cap[i])
> 
> ?
> 
> I'm about to test that change instead of bypassing the loop, so I'll let
> you know the results.
> 

No, this still results in a dead network connection, although it is
probably a correct change.  I suppose giving the loop even more reasons
to return -ERANGE wasn't going to be helpful.

- --
Kevin Winchester

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFHP5KXKPGFQbiQ3tQRAilbAJ9h3qtO9sb9+ctVU0pxzCBjysy06QCdE1Wd
M5V3+0BWyn04p0UeUq/KSlw=
=663t
-----END PGP SIGNATURE-----
