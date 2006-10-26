From: Michael Prokop <mika@grml.org>
Subject: [IPROUTE] manpage for lnstat
Date: Thu, 26 Oct 2006 22:41:26 +0200
Message-ID: <2006-10-26T22-36-55@devnull.michael-prokop.at>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="PiwlZlBV+tXGhOnf"
Cc: shemminger@osdl.org, Harald Welte <laforge@gnumonks.org>,
	Alexander Wirt <formorer@debian.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static.88-198-184-147.clients.your-server.de ([88.198.184.147]:482
	"EHLO mail.michael-prokop.at") by vger.kernel.org with ESMTP
	id S1423542AbWJZUl3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Oct 2006 16:41:29 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--PiwlZlBV+tXGhOnf
Content-Type: multipart/mixed; boundary="+mVf78ABtUsDvBix"
Content-Disposition: inline


--+mVf78ABtUsDvBix
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hello,

I wrote a manpage for lnstat, would be great if it could be applied
to the next release.

@Harald, I'm following your 'If somebody wants to do a manpage, feel
free to send me a patch :)' of lnstat's README. :)

regards,
-mika-

--+mVf78ABtUsDvBix
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="lnstat.1"

.TH LNSTAT 1
.SH NAME
lnstat \- unified linux network statistics
.SH SYNOPSIS
.B lnstat
.RI [ options ]
.SH DESCRIPTION
This manual page documents briefly the
.B lnstat
command.
.PP
\fBlnstat\fP is a generalized and more feature-complete replacement for the old rtstat program.
In addition to routing cache statistics, it supports any kind of statistics the linux kernel
exports via a file in /proc/net/stat/.
.SH OPTIONS
These programs follow the usual GNU command line syntax, with long
options starting with two dashes (`-').
lnstat supports the following options.
.TP
.B \-h, \-\-help
Show summary of options.
.TP
.B \-V, \-\-version
Show version of program.
.TP
.B \-c, \-\-count <count>
Print <count> number of intervals.
.TP
.B \-d, \-\-dump
Dump list of available files/keys.
.TP
.B \-f, \-\-file <file>
Statistics file to use.
.TP
.B \-i, \-\-interval <intv>
Set interval to 'intv' seconds.
.TP
.B \-k, \-\-keys k,k,k,...
Display only keys specified.
.TP
.B \-s, \-\-subject [0-2]
Specify display of subject/header. '0' means no header at all, '1' prints a header only at start of the program and '2' prints a header every 20 lines.
.TP
.B \-w, \-\-width n,n,n,...
Width for each field.
.SH USAGE EXAMPLES
.TP
.B # lnstat -d
Get a list of supported statistics files.
.TP
.B # lnstat -k arp_cache:entries,rt_cache:in_hit,arp_cache:destroys
Select the specified files and keys.
.TP
.B # lnstat -i 10
Use an interval of 10 seconds.
.TP
.B # lnstat -f ip_conntrack
Use only the specified file for statistics.
.TP
.B # lnstat -s 0
Do not print a header at all.
.TP
.B # lnstat -s 20
Print a header at start and every 20 lines.
.TP
.B # lnstat -c -1 -i 1 -f rt_cache -k entries,in_hit,in_slow_tot
Display statistics for keys entries, in_hit and in_slow_tot of field rt_cache every second.
.SH SEE ALSO
.BR ip (8),
and /usr/share/doc/iproute-doc/README.lnstat (package iproute-doc on Debian)
.br
.SH AUTHOR
lnstat was written by Harald Welte <laforge@gnumonks.org>.
.PP
This manual page was written by Michael Prokop <mika@grml.org> for the Debian project (but may be used by others).

--+mVf78ABtUsDvBix--

--PiwlZlBV+tXGhOnf
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQFFQR112N9T+zficugRArSfAJ9Q5BiiAgp/asAK8n/3gF2DutYYrQCfZKt4
y0AQRr0v+Tux5xXZChruQ4w=
=xFZw
-----END PGP SIGNATURE-----

--PiwlZlBV+tXGhOnf--
