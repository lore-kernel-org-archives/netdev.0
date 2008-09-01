From: Valdis.Kletnieks@vt.edu
Subject: Re: loaded router, excessive getnstimeofday in oprofile
Date: Mon, 01 Sep 2008 00:08:14 -0400
Message-ID: <6720.1220242094@turing-police.cc.vt.edu>
References: <21915755.1327801219904892242.JavaMail.root@ouachita> <48B6E7D0.5070307@hp.com> <20031.1220236756@turing-police.cc.vt.edu>
            <20080831.205145.225080276.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1220242094_3529P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, jmalicki@metacarta.com, andi@firstfloor.org,
	johnpol@2ka.mipt.ru, dada1@cosmosbay.com, denys@visp.net.lb,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	juhlenko@akamai.com, sammy@sammy.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from turing-police.cc.vt.edu ([128.173.14.107]:40552 "EHLO
	turing-police.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750987AbYIAEIg (ORCPT
	<RFC822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 00:08:36 -0400
In-Reply-To: Your message of "Sun, 31 Aug 2008 20:51:45 PDT."
             <20080831.205145.225080276.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--==_Exmh_1220242094_3529P
Content-Type: text/plain; charset=us-ascii

On Sun, 31 Aug 2008 20:51:45 PDT, David Miller said:

> Many trades are made programaticcally using formulas and computer
> algorithms in response to market activity and other trades of the
> same security.
> 
> There is no typing involved :)

Still the same issue - the time delay in getting the ticker tape values
back, making the decision, and launching the transaction are *way* bigger
than the packet queueing order.  Think - trading a few billion shares a day,
if that ticker is even 5 seconds behind, *that* is a much bigger issue than
what order the transactions happen in...

> If the financial folks say they need this stuff, then unless we're
> prepared to become experts in financial markets and how the IT stuff
> for them are designed and run, we might as well just trust them on
> this one.

The toughest part of systems analysis is getting the user to shut up about
what they say they need long enough for you to find out what it is they
are actually trying to do.

Quite frankly, unless somebody *IS* planning to become an expert on how the
IT stuff for them are designed and run, we *should not* be doing any code
changes that we don't understand, just because they say so and we should
trust them...

--==_Exmh_1220242094_3529P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFIu2qucC3lWbTT17ARAjxJAJ0ZfkmllygrI6OHbfwiffyUUcRdeACfYtjn
r5t5NmUR4CWzJ4A+tBY9+PY=
=9cER
-----END PGP SIGNATURE-----

--==_Exmh_1220242094_3529P--
