From: Valdis.Kletnieks@vt.edu
Subject: Re: Divide error in bictcp_cong_avoid ?
Date: Wed, 04 May 2011 15:31:21 -0400
Message-ID: <16668.1304537481@localhost>
References: <4DC178D3.6030308@techboom.com> <20110504104940.cd0d9e9a.rdunlap@xenotime.net>
            <20110504113351.4643a0c9@nehalam>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1304537481_7352P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: Randy Dunlap <rdunlap@xenotime.net>, TB <lkml@techboom.com>,
	netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lennier.cc.vt.edu ([198.82.162.213]:36532 "EHLO
	lennier.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754399Ab1EDTbZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 15:31:25 -0400
In-Reply-To: Your message of "Wed, 04 May 2011 11:33:51 PDT."
             <20110504113351.4643a0c9@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--==_Exmh_1304537481_7352P
Content-Type: text/plain; charset=us-ascii

On Wed, 04 May 2011 11:33:51 PDT, Stephen Hemminger said:

> What kernel version? I suspect they are running something really old
> kernel like RHEL 5 since BIC has not been the default congestion control for
> several years.

Pretty bleeding edge here, and BIC is *still* the default:

% uname -a
Linux turing-police.cc.vt.edu 2.6.39-rc5-mmotm0429 #1 SMP PREEMPT Sat Apr 30 00:36:49 EDT 2011 x86_64 x86_64 x86_64 GNU/Linux
% zgrep -i BIC /proc/config.gz 
CONFIG_TCP_CONG_BIC=y
CONFIG_TCP_CONG_CUBIC=m
CONFIG_DEFAULT_BIC=y
CONFIG_DEFAULT_TCP_CONG="bic"

Why? Because BIC was working "well enough", so I never changed it by hand, and
"make oldconfig" never changed it automagically either.  Now, 


--==_Exmh_1304537481_7352P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFNwamJcC3lWbTT17ARAr+6AKCdKmV8Bq6F2lh5wEq46/cyi4js6wCfXz40
wcMPCc17PaxksJCuEB56UdQ=
=0NR+
-----END PGP SIGNATURE-----

--==_Exmh_1304537481_7352P--

