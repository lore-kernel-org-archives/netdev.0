From: Michael Prokop <mika@grml.org>
Subject: [IPROUTE] manpage for rtmon
Date: Fri, 27 Oct 2006 19:22:11 +0200
Message-ID: <2006-10-27T19-06-18@devnull.michael-prokop.at>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="xdFnWCcMW4kMaGnb"
Cc: Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static.88-198-184-147.clients.your-server.de ([88.198.184.147]:3006
	"EHLO mail.michael-prokop.at") by vger.kernel.org with ESMTP
	id S1751312AbWJ0RWO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Oct 2006 13:22:14 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--xdFnWCcMW4kMaGnb
Content-Type: multipart/mixed; boundary="ICzQLVUlUjFtnNCj"
Content-Disposition: inline


--ICzQLVUlUjFtnNCj
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello,

another manpage, this time for rtmon. Would be great if it could be
applied to the next release too.

regards,
-mika-
--=20
 ,'"`.         http://www.michael-prokop.at/
(  grml.org -=BB Linux Live-CD for texttool-users and sysadmins
 `._,'         http://www.grml.org/

--ICzQLVUlUjFtnNCj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="rtmon.8"

.TH RTMON 8
.SH NAME
rtmon \- listens to and monitors RTnetlink
.SH SYNOPSIS
.B rtmon
.RI "[ options ] file FILE [ all | LISTofOBJECTS ]"
.SH DESCRIPTION
This manual page documents briefly the
.B rtmon
command.
.PP
\fBrtmon\fP is a RTnetlink listener. RTnetlink allows the kernel's routing tables to be read and altered.

rtmon should be started before the first network configuration command is issued. For example if you insert:

 rtmon file /var/log/rtmon.log

in a startup script, you will be able to view the full history later.
Certainly, it is possible to start rtmon at any time. It prepends the history with the state snapshot dumped at the moment of starting.
.SH OPTIONS
rtmon supports the following options:
.TP
.B \-Version
Print version and exit.
.TP
.B help
Show summary of options.
.TP
.B file FILE [ all | LISTofOBJECTS ]
Log output to FILE. LISTofOBJECTS is the list of object types that we want to monitor.
It may contain 'link', 'address', 'route' and 'all'. 'link' specifies the network device, 'address'
the protocol (IP or IPv6) address on a device, 'route' the routing table entry and 'all' does what the name says.
.TP
.B \-family [ inet | inet6 | link | help ]
Specify protocol family. 'inet' is IPv4, 'inet6' is IPv6, 'link' means that no networking protocol is involved and 'help' prints usage information.
.TP
.B \-4
Use IPv4. Shortcut for -family inet.
.TP
.B \-6
Use IPv6. Shortcut for -family inet6.
.TP
.B \-0
Use a special family identifier meaning that no networking protocol is involved. Shortcut for -family link.
.SH USAGE EXAMPLES
.TP
.B # rtmon file /var/log/rtmon.log
Log to file /var/log/rtmon.log, then run:
.TP
.B # ip monitor file /var/log/rtmon.log
to display logged output from file.
.SH SEE ALSO
.BR ip (8)
.SH AUTHOR
rtmon was written by Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>.
.PP
This manual page was written by Michael Prokop <mika@grml.org>,
for the Debian project (but may be used by others).

--ICzQLVUlUjFtnNCj--

--xdFnWCcMW4kMaGnb
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQFFQkBD2N9T+zficugRAm8lAJoDUkc2CVoTUGft1ZXuc+01D15p8gCeKc0O
0+fxvu41yo8R2WlxP90H0KQ=
=iHPR
-----END PGP SIGNATURE-----

--xdFnWCcMW4kMaGnb--
