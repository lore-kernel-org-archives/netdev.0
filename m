From: Valdis.Kletnieks@vt.edu
Subject: Re: TCP port firewall controlled by UDP packets
Date: Fri, 12 Aug 2011 15:25:10 -0400
Message-ID: <14788.1313177110@turing-police.cc.vt.edu>
References: <1313106969-18733-1-git-send-email-as@strmilov.cz> <20110811171317.271be88b.rdunlap@xenotime.net>
            <4E45482B.7080207@strmilov.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1313177110_2634P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: Randy Dunlap <rdunlap@xenotime.net>, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Antonin Steinhauser <as@strmilov.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: Your message of "Fri, 12 Aug 2011 17:35:07 +0200."
             <4E45482B.7080207@strmilov.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1313177110_2634P
Content-Type: text/plain; charset=us-ascii

On Fri, 12 Aug 2011 17:35:07 +0200, Antonin Steinhauser said:
> Dne 12.8.2011 02:13, Randy Dunlap napsal(a):
> > On Fri, 12 Aug 2011 01:56:09 +0200 Tonda wrote:
> >> +config TCPFIREWALL
> >> +	tristate "TCP Firewall controlled by UDP queries"
> >> +	depends on m
> >>
> > Why buildable only as a loadable module?
> >
> >
> Because it needs parameter - address of inet_protos table from
> /boot/System_map

That's probably a very good indication that you're doing it the wrong way, and
need to redesign what you're doing....


--==_Exmh_1313177110_2634P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFORX4WcC3lWbTT17ARAuhFAKCDyXIT+ig4eR06XyzBXCt48dZboACePLl7
TWBfv0/q2LLg7EOYbPZ51AY=
=+t5Z
-----END PGP SIGNATURE-----

--==_Exmh_1313177110_2634P--
