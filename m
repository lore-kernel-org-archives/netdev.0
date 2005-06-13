From: Valdis.Kletnieks@vt.edu
Subject: Re: [PATCH] fix small DoS on connect() (was Re: BUG: Unusual TCP Connect() results.)
Date: Sun, 12 Jun 2005 22:04:12 -0400
Message-ID: <200506130204.j5D24EOE005565__36706.9714506671$1118628439$gmane$org@turing-police.cc.vt.edu>
References: <42A9C607.4030209@unixtrix.com> <200506122010.33075.vda@ilport.com.ua> <20050612173614.GA11157@alpha.home.local> <200506122047.07257.vda@ilport.com.ua>
            <20050612181425.GA11284@alpha.home.local>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1118628251_24934P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: Denis Vlasenko <vda@ilport.com.ua>,
        "David S. Miller" <davem@davemloft.net>, xschmi00@stud.feec.vutbr.cz,
        alastair@unixtrix.com, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Willy Tarreau <willy@w.ods.org>
In-Reply-To: Your message of "Sun, 12 Jun 2005 20:14:25 +0200."
             <20050612181425.GA11284@alpha.home.local>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--==_Exmh_1118628251_24934P
Content-Type: text/plain; charset=us-ascii

On Sun, 12 Jun 2005 20:14:25 +0200, Willy Tarreau said:
> On Sun, Jun 12, 2005 at 08:47:07PM +0300, Denis Vlasenko wrote:

> > Very nice. BTW, is there any real world applications which
> > ever used this?
> 
> Not that I'm aware of, but that does not mean they don't exist. Until
> yesterday, I even thought that it was never implemented. As most other
> systems don't implement it, the applications, if they exist, are Linux
> or BSD-dependant.

A more likely explanation is that there existed TOPS-20 or Multics code
that actually used that for something.  Remember that BSD and Linux both
came along long after RFC793 came out....

--==_Exmh_1118628251_24934P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFCrOmbcC3lWbTT17ARAh6UAKDllrvzzA/u7DLz7U465OhXZSqJLACg8e8B
SVOuvr28yBxqHicG3qQptUg=
=Bwr2
-----END PGP SIGNATURE-----

--==_Exmh_1118628251_24934P--
