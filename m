From: Valdis.Kletnieks@vt.edu
Subject: Re: mmotm 2010-05-11 - dies in pm_qos_update_request()
Date: Wed, 12 May 2010 18:12:50 -0400
Message-ID: <17286.1273702370@localhost>
References: <201005120149.o4C1n7P4002637@imap1.linux-foundation.org> <5525.1273693962@localhost>
            <201005122307.20860.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1273702370_3904P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lennier.cc.vt.edu ([198.82.162.213]:55884 "EHLO
	lennier.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753506Ab0ELWNK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 May 2010 18:13:10 -0400
In-Reply-To: Your message of "Wed, 12 May 2010 23:07:20 +0200."
             <201005122307.20860.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--==_Exmh_1273702370_3904P
Content-Type: text/plain; charset=us-ascii

On Wed, 12 May 2010 23:07:20 +0200, "Rafael J. Wysocki" said:
 
> > I suspect this commit:
> > 
> > commit 23606cf5d1192c2b17912cb2ef6e62f9b11de133
> > Author: Rafael J. Wysocki <rjw@sisk.pl>
> > Date:   Sun Mar 14 14:35:17 2010 +0000
> > 
> >     e1000e / PCI / PM: Add basic runtime PM support (rev. 4)
> 
> No, I don't think so.  I'm running -rc6 with this patch applied on a box with
> e1000e and it works just fine.
> 
> Please try to revert this one instead:
> 
> http://git.kernel.org/?p=linux/kernel/git/rafael/suspend-2.6.git;a=patch;h=ed77134bfccf5e75b6cbadab268e559dbe6a4ebb

Isn't a clean revert - build dies with:

  CC      net/mac80211/scan.o
net/mac80211/scan.c: In function 'ieee80211_scan_state_decision':
net/mac80211/scan.c:510: error: implicit declaration of function 'pm_qos_request'
make[1]: *** [net/mac80211/scan.o] Error 1
make: *** [net/mac80211/scan.o] Error 2

Will investigate more later, find what other commit needs reverting.

--==_Exmh_1273702370_3904P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFL6yficC3lWbTT17ARAg4GAJ4mP56FJ4j7BKFY+fx3EYZn3WBjBACgiNks
IfrHw5PXW5twuBm29VbGzkw=
=l25Q
-----END PGP SIGNATURE-----

--==_Exmh_1273702370_3904P--

