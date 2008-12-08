From: Valdis.Kletnieks@vt.edu
Subject: Re: [RFC] New functions to manipulate registers for ethtool
Date: Mon, 08 Dec 2008 04:01:43 -0500
Message-ID: <58622.1228726903@turing-police.cc.vt.edu>
References: <20081208171230.288c5ccf.mitake@clustcom.com>
            <20081208.005431.200957157.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1228726903_54791P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: mitake@clustcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ktaka@clustcom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from turing-police.cc.vt.edu ([128.173.14.107]:53372 "EHLO
	turing-police.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751301AbYLHJBv (ORCPT
	<RFC822;netdev@vger.kernel.org>); Mon, 8 Dec 2008 04:01:51 -0500
In-Reply-To: Your message of "Mon, 08 Dec 2008 00:54:31 PST."
             <20081208.005431.200957157.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--==_Exmh_1228726903_54791P
Content-Type: text/plain; charset=us-ascii

On Mon, 08 Dec 2008 00:54:31 PST, David Miller said:
> From: Hitoshi Mitake <mitake@clustcom.com>
> Date: Mon, 8 Dec 2008 17:12:30 +0900
> 
> > I want to add two new functions to ethtool.
> > 
> > One is for setting driver's registers on MMIO area like
> > --change-eeprom option.
> 
> You can map the registers into userspace using the bus
> level mmap facilities exported to userspace.
> 
> No ethtool support is necessary for this.

Yes, but if Hitoshi wants to tell a user "run this command and send me
the output", what's the incantation the user needs to use?

The user probably has ethtool installed if they have a semi-sane distro.
Their eyeballs are just gonna glaze over if they're asked to map the registers
into userspace.. ;)

--==_Exmh_1228726903_54791P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFJPOJ3cC3lWbTT17ARApwYAJ4wYzvoRxJD4uaTNMr0l42UMHW7DgCfTp5F
n70UfZ8hONEHi2x7Bc69RvU=
=SrQR
-----END PGP SIGNATURE-----

--==_Exmh_1228726903_54791P--
