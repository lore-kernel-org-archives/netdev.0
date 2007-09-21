From: Valdis.Kletnieks@vt.edu
Subject: Re: [PATCH 1/2] bnx2: factor out gzip unpacker
Date: Fri, 21 Sep 2007 15:32:58 -0400
Message-ID: <4075.1190403178@turing-police.cc.vt.edu>
References: <200709211201.24475.vda.linux@googlemail.com> <200709211905.23946.vda.linux@googlemail.com> <15775.1190399812@turing-police.cc.vt.edu>
            <200709212018.06553.vda.linux@googlemail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1190403178_2846P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jeff@garzik.org,
	mchan@broadcom.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Denys Vlasenko <vda.linux@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from turing-police.cc.vt.edu ([128.173.14.107]:60955 "EHLO
	turing-police.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753953AbXIUTdI (ORCPT
	<RFC822;netdev@vger.kernel.org>); Fri, 21 Sep 2007 15:33:08 -0400
In-Reply-To: Your message of "Fri, 21 Sep 2007 20:18:06 BST."
             <200709212018.06553.vda.linux@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1190403178_2846P
Content-Type: text/plain; charset=us-ascii

On Fri, 21 Sep 2007 20:18:06 BST, Denys Vlasenko said:
> On Friday 21 September 2007 19:36, Valdis.Kletnieks@vt.edu wrote:
> > Should this be redone to use the existing firmware loading framework to
> > load the firmware instead?
> 
> Not in every case.
> 
> For example, bnx2 maintainer says that driver and
> firmware are closely tied for his driver. IOW: you upgrade kernel
> and your NIC is not working anymore.
> 
> Another argument is to make kernel be able to bring up NICs
> without needing firmware images in initramfs/initrd/hard drive.

OK, I can live with "considered and decided against". :)

--==_Exmh_1190403178_2846P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFG9BxqcC3lWbTT17ARAowoAJ93dHExLCVbs4nP4CWw59I0oo83ewCg1wRn
JawoiXIYnbdoq13TpOB5vl4=
=hhMn
-----END PGP SIGNATURE-----

--==_Exmh_1190403178_2846P--
