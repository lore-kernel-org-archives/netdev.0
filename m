From: "Steven J. Hill" <sjhill@realitydiluted.com>
Subject: Re: [PATCH] Merge GT/MV642xx Support into MV643xx Driver [7/8]
Date: Thu, 19 Jul 2007 21:10:26 -0500
Message-ID: <46A01992.1060907@realitydiluted.com>
References: <469EEF13.2000607@realitydiluted.com> <20070719142159.GF12892@xyzzy.farnsworth.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from real.realitydiluted.com ([66.43.201.61]:51433 "EHLO
	real.realitydiluted.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752320AbXGTCK0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 22:10:26 -0400
In-Reply-To: <20070719142159.GF12892@xyzzy.farnsworth.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Dale Farnsworth wrote:
> 
> You have replaced the use of the global PHY spinlock with a per-port spinlock.
> However, the SMI register is shared by all ports.  The global lock is
> needed to prevent simultaneous updates of the register by drivers for
> multiple ports.
> 
> NAK
>
Are you sure? Notice that a majority of the spinlocks were changed to disable
IRQs. Secondly, the lowest level mv_read/mv_write functions have to acquire
the big mv64x60_lock before they can read or write registers. I see the PHY
spinlock as being an additional and unnecessary lock to contend with. Am I
make an improper assumption?

- -Steve
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFGoBmSgyK5H2Ic36cRAj8JAKCfmg/T2FgOdYZ5YfnXJsiyn3RkaQCfadSk
GS8ICyW0+qNRHr5QqnY0PUQ=
=nvSB
-----END PGP SIGNATURE-----
