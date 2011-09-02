From: Valdis.Kletnieks@vt.edu
Subject: Re: [next] unix stream crashes
Date: Thu, 01 Sep 2011 20:49:19 -0400
Message-ID: <3179.1314924559@turing-police.cc.vt.edu>
References: <4E5FEF28.60406@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1314924559_3073P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: tim.c.chen@linux.intel.com,
	"David S. Miller" <davem@davemloft.net>,
	ML netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Jiri Slaby <jirislaby@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: Your message of "Thu, 01 Sep 2011 22:46:32 +0200."
             <4E5FEF28.60406@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1314924559_3073P
Content-Type: text/plain; charset=us-ascii

On Thu, 01 Sep 2011 22:46:32 +0200, Jiri Slaby said:
> Hi,
> 
> my box 100% crashes when booting. It's both in unix socket recv and send 
> paths. I've reverted 0856a30409 (Scm: Remove unnecessary pid & 
> credential references in Unix socket's send and receive path) and it 
> seems to help.
> 
> The oops:
> http://www.fi.muni.cz/~xslaby/sklad/panics/af_unix_crash.png

I was seeing a 100% repeatable crash with the X server starting as well, but
wasn't able to get a traceback because my X server was doing the modeset before
it crashed (so all I got was a black screen) and netconsole is busticated for
me.  I can confirm that reverting that one commit allows my box to boot and get
X up and running as well.


--==_Exmh_1314924559_3073P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFOYCgPcC3lWbTT17ARAmDBAKDUhUb6Lcsk2lG9y3YzY+ElVp12bQCg4C/j
0U1hhZYPxQ4/8cRVZJGZgow=
=TRzo
-----END PGP SIGNATURE-----

--==_Exmh_1314924559_3073P--
