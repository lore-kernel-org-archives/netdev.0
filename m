From: Valdis.Kletnieks@vt.edu
Subject: Re: Fw: 2.6.18-rc4-mm3: BUG: warning at include/net/dst.h:154/dst_release()
Date: Tue, 29 Aug 2006 17:43:05 -0400
Message-ID: <200608292143.k7TLh51P003039@turing-police.cc.vt.edu>
References: <20060829091656.d4158404.akpm@osdl.org>
            <20060829182433.GB3470@postel.suug.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1156887785_2978P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from turing-police.cc.vt.edu ([128.173.14.107]:60831 "EHLO
	turing-police.cc.vt.edu") by vger.kernel.org with ESMTP
	id S965426AbWH2VnP (ORCPT <RFC822;netdev@vger.kernel.org>);
	Tue, 29 Aug 2006 17:43:15 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: Your message of "Tue, 29 Aug 2006 20:24:33 +0200."
             <20060829182433.GB3470@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1156887785_2978P
Content-Type: text/plain; charset=us-ascii

On Tue, 29 Aug 2006 20:24:33 +0200, Thomas Graf said:

> > Seeing this a lot on 2.6.18-rc4-mm3 with 2 different stack tracebacks
> > (one for received packets, other for sending).  I already picked up the
> > fix for the ^ / confusion in fib_rules.c and that didn't help matters.
> 
> Should be fixed by this patch:
> 
> commit 4305fabb7e4c63ddc3a4fd38aab9ec3f6575b111
> Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Date:   Mon Aug 28 13:19:30 2006 -0700
> 
>     [IPV6] ROUTE: Fix dst reference counting in ip6_pol_route_lookup().
> 
>     In ip6_pol_route_lookup(), when we finish backtracking at the
>     top-level root entry, we need to hold it.

Confirming patch fixes the problem I'm seeing, thanks...

--==_Exmh_1156887785_2978P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFE9LTpcC3lWbTT17ARAo+SAKDJAMyRPQoZM4V7cGL9KXq/9ucr4QCfSMAu
bF415yFjDa16jl9sA4QSOmk=
=dhOO
-----END PGP SIGNATURE-----

--==_Exmh_1156887785_2978P--
