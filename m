From: Valdis.Kletnieks@vt.edu
Subject: Re: 2.6.28-git8: tg3 doesn't work due to firmware not loading (-git7 is ok)
Date: Sun, 11 Jan 2009 06:10:58 -0500
Message-ID: <43805.1231672258@turing-police.cc.vt.edu>
References: <5a4c581d0901081233y6b546167sbe3ed9f2ea37f1f9@mail.gmail.com> <20090108.125331.03608787.davem@davemloft.net> <5a4c581d0901090930j5d4760b0x730b5609fa2b5614@mail.gmail.com>
            <20090109.140422.60087297.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1231672258_4078P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: alessandro.suardi@gmail.com, jaswinderlinux@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	dwmw2@infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from turing-police.cc.vt.edu ([128.173.14.107]:51871 "EHLO
	turing-police.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750938AbZAKLLI (ORCPT
	<RFC822;netdev@vger.kernel.org>); Sun, 11 Jan 2009 06:11:08 -0500
In-Reply-To: Your message of "Fri, 09 Jan 2009 14:04:22 PST."
             <20090109.140422.60087297.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--==_Exmh_1231672258_4078P
Content-Type: text/plain; charset=us-ascii

On Fri, 09 Jan 2009 14:04:22 PST, David Miller said:
> From: "Alessandro Suardi" <alessandro.suardi@gmail.com>
> Date: Fri, 9 Jan 2009 18:30:40 +0100
> 
> > Clearly the requirement changed in -git8, AFAICS.
> 
> Because -git8 is where the firmware requirement got added.
> 
> If you build the TG3 driver statically into your kernel,
> the only way to get the firmware properly loaded is to
> enable that CONFIG_FIRMWARE_IN_KERNEL option.

Maybe this is one of those cases where we actually do want a SELECT?

	select FIRMWARE_IN_KERNEL if TIGON3=y

or similar?

--==_Exmh_1231672258_4078P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFJadPCcC3lWbTT17ARAq/mAJ9i0L89DnH4b63OSy89fNFJLFyY5ACfW8xy
qfn7lWQiu+ANURHa1W5Jbt8=
=83EK
-----END PGP SIGNATURE-----

--==_Exmh_1231672258_4078P--
