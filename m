From: Vladimir Kondratiev <vkondra@mail.ru>
Subject: Re: [RFC] acx100 inclusion in mainline; generic 802.11 stack
Date: Thu, 9 Sep 2004 00:54:47 +0300
Sender: acx100-devel-admin@lists.sourceforge.net
Message-ID: <200409090815.40358.vkondra@mail.ru>
References: <200408312111.02438.vda@port.imtp.ilyichevsk.odessa.ua> <200409082251.45771.vkondra@mail.ru> <413F70F0.6020709@atheros.com>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1592424.FD8qnxMVIZ";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: greg chesson <greg@atheros.com>,
 "David S. Miller" <davem@davemloft.net>,
 acx100-devel@lists.sourceforge.net,
 hadi@cyberus.ca,
 jgarzik@pobox.com,
 jkmaline@cc.hut.fi,
 prism54-devel@prism54.org,
 sam@errno.com,
 vda@port.imtp.ilyichevsk.odessa.ua
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: netdev@oss.sgi.com
In-Reply-To: <413F70F0.6020709@atheros.com>
Errors-To: acx100-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:acx100-devel@lists.sourceforge.net>
List-Help: <mailto:acx100-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=acx100-devel>
List-Id: netdev.vger.kernel.org

--nextPart1592424.FD8qnxMVIZ
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

gc>
gc> Linux does the same thing (driver is configured by application code)
gc>   although there does not yet exist a single app
gc> that can serve as a common point of control for multiple vendor drivers.
gc> I believe that achieving that goal is the real payoff for wireless Linux
gc> users.

I would not fully agree here: for timing reasons, you can do scanning/AP=20
selection in user space, but for rate scaling, if we ever can do it generic=
,=20
you better be in kernel.
=46rom architecture point of view, MLME should be stack, not user app. For =
me,=20
management packets generation is same kind of activity as arp.=20

gc>
gc> > It is simply waste of resources.
gc> >
gc> > To make step forward, I suggest the following:
gc> >
gc> > 1. Dave's code is at least year old. someone need to start maintain i=
t,
gc> > starting with update for current kernel infrastructure. Get it compile
 and gc> > load for 2.6.9, for example.
gc> >
gc> > 2. To debug stack, you don't need real driver. I can write dummy .11
 driver gc> > that will silently discard all Tx, and will provide some way
 for user level gc> > tool to simulate Rx (ioctl, netlink, does not really
 matter). For logic, it gc> > is sufficient. Later, when it will come to
 timing, performance etc, it will gc> > be easy to strip some real driver.
gc> >
gc> > This may be king of "proof of concept".
gc>
gc> Yes, for logic it is sufficient.
gc> My personal approach would be to test the theory by examining
gc> what fits or doesn't fit into David's API if I were to port one of the
gc> MLME implementations that I work with.   Discover if it fits or not.

Sounds promising. Don't forget to share you findings.

--nextPart1592424.FD8qnxMVIZ
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBBP+b7qxdj7mhC6o0RAnVMAKCLcqspPDtHQ094POfHlsBkQkPheQCeLQMS
bxubWRBaaZ6IlUdPinIB6YE=
=UHCq
-----END PGP SIGNATURE-----

--nextPart1592424.FD8qnxMVIZ--


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
