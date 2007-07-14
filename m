From: Valdis.Kletnieks@vt.edu
Subject: Re: [2.6 patch] cleanup congestion control options
Date: Sat, 14 Jul 2007 00:59:30 -0400
Message-ID: <4992.1184389170@turing-police.cc.vt.edu>
References: <20070714040953.GE3565@stusta.de>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1184389170_3376P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from turing-police.cc.vt.edu ([128.173.14.107]:52330 "EHLO
	turing-police.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750827AbXGNFAf (ORCPT
	<RFC822;netdev@vger.kernel.org>); Sat, 14 Jul 2007 01:00:35 -0400
In-Reply-To: Your message of "Sat, 14 Jul 2007 06:09:54 +0200."
             <20070714040953.GE3565@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1184389170_3376P
Content-Type: text/plain; charset=us-ascii

On Sat, 14 Jul 2007 06:09:54 +0200, Adrian Bunk said:
> This patch contains the following cleanups:
> - note in the prompt if an option depends on EXPERIMENTAL

Who decided whether a particular option is 'experimental' or not?

Lawrence S. Brakmo and Larry L. Peterson. TCP Vegas: end to end congestion
avoidance on a global Internet. IEEE Journal on Selected Areas in
Communications, 13(8), October 1995.

>  config TCP_CONG_VEGAS
> -	tristate "TCP Vegas"
> +	tristate "TCP Vegas (EXPERIMENTAL)"
>  	depends on EXPERIMENTAL

I think the *right* fix here is '- depends on EXPERIMENTAL'.  1995. Geez. :)

(Probably *all* of the 'experimental' tags for congestion control need an in-depth
review - but Vegas struck me as particularly egregious.)


--==_Exmh_1184389170_3376P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFGmFgycC3lWbTT17ARAtlyAKCLmarBpPMr4y/EMGceX7+xglJcYwCdE9E7
EAwSSdx8W1Qmvq4IfBeBj38=
=FDgm
-----END PGP SIGNATURE-----

--==_Exmh_1184389170_3376P--
