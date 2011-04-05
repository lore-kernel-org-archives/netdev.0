From: Valdis.Kletnieks@vt.edu
Subject: Re: [PATCH 12/34] isdn/diva: Drop __TIME__ usage
Date: Tue, 05 Apr 2011 15:17:36 -0400
Message-ID: <20627.1302031056@localhost>
References: <1302015561-21047-1-git-send-email-mmarek@suse.cz> <1302015561-21047-13-git-send-email-mmarek@suse.cz>
            <alpine.DEB.2.00.1104051709040.7262@justus.melware.de>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1302031056_4766P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: Michal Marek <mmarek@suse.cz>, linux-kbuild@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Armin Schindler <armin@melware.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lennier.cc.vt.edu ([198.82.162.213]:40883 "EHLO
	lennier.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754307Ab1DETRn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 15:17:43 -0400
In-Reply-To: Your message of "Tue, 05 Apr 2011 17:10:34 +0200."
             <alpine.DEB.2.00.1104051709040.7262@justus.melware.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--==_Exmh_1302031056_4766P
Content-Type: text/plain; charset=us-ascii

On Tue, 05 Apr 2011 17:10:34 +0200, Armin Schindler said:
> On Tue, 5 Apr 2011, Michal Marek wrote:
> > The kernel already prints its build timestamp during boot, no need to
> > repeat it in random drivers and produce different object files each
> > time.
> 
> The module can be build separately from the kernel, therefore it can have
> an own build timestamp.

If the same code is being built as an out-of-tree module, that's a possibly
good reason for a code version variable, but what does the build timestamp
actually tell you?  If you already know foo_driver.c version 0.814 was buiilt
against 2.6.41-rc2, in what cases does it matter if the compile was on Tuesday
or Thursday - especially since an 'ls -l foo_driver.ko' will tell you?  If it's
a matter of "the target .config changed on Wednesday", a build timestamp still
doesn't help over 'ls -l'.


--==_Exmh_1302031056_4766P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFNm2rQcC3lWbTT17ARAoBZAKDnh8ChIPQ+yitrNK1VhQT4oAxrTQCeKw1t
kliGImEzd5WLgHkBid0pTps=
=6wj5
-----END PGP SIGNATURE-----

--==_Exmh_1302031056_4766P--

