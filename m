From: Andrew Morgan <morgan@kernel.org>
Subject: Re: 2.6.24-rc2-mm1 -- strange apparent network failures
Date: Sat, 17 Nov 2007 17:57:22 -0800
Message-ID: <473F9C02.1040401@kernel.org>
References: <20071113175906.497a1a6a.akpm@linux-foundation.org> <20071115164441.67a8e2df.akpm@linux-foundation.org> <473E794A.4060107@kernel.org> <200711170848.35726.kjwinchester@gmail.com> <473F7EDB.60701@kernel.org> <473F8C46.4070308@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, apw@shadowen.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kamalesh@linux.vnet.ibm.com
To: Kevin Winchester <kjwinchester@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from twinlark.arctic.org ([207.29.250.54]:40675 "EHLO
	twinlark.arctic.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752504AbXKRB53 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Nov 2007 20:57:29 -0500
In-Reply-To: <473F8C46.4070308@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Kevin Winchester wrote:
> However, I got around the problem by making the code change manually -
> and my network connection is now working.  Looking at the code being
> bypassed:
> 
>     if (pE.cap[i] || pP.cap[i] || pP.cap[i])
> 
> looks somewhat weird as it is testing the same condition twice.  Should
> it have been:
> 
>     if (pE.cap[i] || pP.cap[i] || pI.cap[i])

Yes, that was also a bug. However, upon reflection (and as per my "0 &&"
hack), I now believe these few lines of code are problematic in general.

Thanks for reporting this bug. I'll post a more clear patch (that isn't
GPG'd).

Cheers

Andrew
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFHP5vy+bHCR3gb8jsRAliTAKCvCsfZuNN7Og57S0s8O4SZNveSUwCgq4VP
vHUE/S+x09l5I24E2/rmLj4=
=JaWT
-----END PGP SIGNATURE-----
