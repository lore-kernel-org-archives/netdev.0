From: Valdis.Kletnieks@vt.edu
Subject: Re: [PATCH] Re: mmotm 2010-07-19 - e1000e vs. pm_qos_update_request issues
Date: Thu, 22 Jul 2010 00:05:03 -0400
Message-ID: <4222.1279771503@localhost>
References: <201007200007.o6K07Xbg028863@imap1.linux-foundation.org> <6182.1279658125@localhost> <20100720140751.71ee83a8.akpm@linux-foundation.org>
            <20100721091200.40c43158@schatten.dmk.lab>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1279771503_4028P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	mark gross <markgross@thegnar.org>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"David S. Miller" <davem@davemloft.net>
To: Florian Mickler <florian@mickler.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lennier.cc.vt.edu ([198.82.162.213]:55665 "EHLO
	lennier.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751902Ab0GVEFv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 00:05:51 -0400
In-Reply-To: Your message of "Wed, 21 Jul 2010 09:12:00 +0200."
             <20100721091200.40c43158@schatten.dmk.lab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--==_Exmh_1279771503_4028P
Content-Type: text/plain; charset=us-ascii

On Wed, 21 Jul 2010 09:12:00 +0200, Florian Mickler said:

> Attached patch moves the registering from e1000_up to e1000_open and
> the unregistering from e1000_down to e1000_close. 
> It is only compile-tested as I don't have the hardware.

My laptop has the hardware, so I tested it - system does indeed boot
without whinging about this issue.  Feel free to stick in a:

Tested-by: Valdis Kletnieks <valdis.kletnieks@vt.edu>

Thanks for the fast fix. :)

> From 693c71b911ff0845c872261d5704a1d40960722d Mon Sep 17 00:00:00 2001
> From: Florian Mickler <florian@mickler.org>
> Date: Wed, 21 Jul 2010 08:44:21 +0200
> Subject: [PATCH] e1000e: register pm_qos request on hardware activation
> 
> The pm_qos_add_request call has to register the pm_qos request with the pm_qos
> susbsystem before first use of the pm_qos request via
> pm_qos_update_request.
> 
> As pm_qos changed to use plists there is no benefit in registering and
> unregistering the pm_qos request on ifup/ifdown and thus we move the
> registering into e1000_open and the unregistering in e1000_close.



--==_Exmh_1279771503_4028P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFMR8NvcC3lWbTT17ARAnovAJ4yJGfIiGp4RMZf5LOm9Eq6fyS8BQCfTrsA
/YP2bqX3IVi2llrnQEHq23M=
=v8iB
-----END PGP SIGNATURE-----

--==_Exmh_1279771503_4028P--

