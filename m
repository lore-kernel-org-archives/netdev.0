From: Valdis.Kletnieks@vt.edu
Subject: Re: The ultimate TOE design
Date: Thu, 16 Sep 2004 02:33:10 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200409160633.i8G6XClT019796@turing-police.cc.vt.edu>
References: <OF8783A4F6.D566336C-ON88256F10.006E51CE-88256F10.006EDA93@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1833311858P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>, leonid.grossman@s2io.com,
        Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
In-Reply-To: Your message of "Wed, 15 Sep 2004 14:11:04 MDT."
             <OF8783A4F6.D566336C-ON88256F10.006E51CE-88256F10.006EDA93@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--==_Exmh_1833311858P
Content-Type: text/plain; charset=us-ascii

On Wed, 15 Sep 2004 14:11:04 MDT, David Stevens said:

> Why don't we off-load filesystems to disks instead?  Or a graphics
> card that implements X ? :-) I'd rather have shared system resources--
> more flexible. :-)

All depends where in the "cycle of reincarnation" we are at the moment.  Way
back in 1964, IBM released this monster called System/360 - and one of the
things it did was push a *lot* of the disk processing off on the channel and
disk controller using a count-key-data format rather than the fixed-block that
Linux uses. So out on the platters, the disk format would say things like "This
is a 400 byte record, the first 56 of which is a search key". A lot of stuff,
both userspace and OS, used things like 'Search Key Equal' and letting the disk
do all the searching.

There was also this terminal beast called the 3270, which had a local
controller for the terminals, and only interrupted the CPU on 'page send' type
events.

Back then, the ideas made sense - it wasn't at all unreasonable for a single
S/360-65 to drive 3,000+ concurrent terminals in an airline reservation system or
similar (and we're talking about a box that had literally only half the
hamsters of a VAX780).

But today, the 3270 isn't seen much anymore, and currently IBM emulates the CKD
format on fixed-block systems for their z/Series boxes running z/OS or whatever MVS is
called now....


--==_Exmh_1833311858P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFBSTOmcC3lWbTT17ARAmroAJ4t/GYMC09woAJLa4BvbV4TgxoNWwCgg0cW
y50v9EReZojc6s9/HwxVc58=
=yw9V
-----END PGP SIGNATURE-----

--==_Exmh_1833311858P--
