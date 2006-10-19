From: Alexander Wirt <formorer@debian.org>
Subject: [IPROUTE] 2nd try
Date: Thu, 19 Oct 2006 06:45:54 +0200
Message-ID: <20061019044554.GB2936@formorer.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="fUYQa+Pmc3FrFX/N"
Cc: shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadowland.snow-crash.org ([80.190.250.253]:26241 "EHLO
	ned.snow-crash.org") by vger.kernel.org with ESMTP id S1030302AbWJSEqM
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Oct 2006 00:46:12 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--fUYQa+Pmc3FrFX/N
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

I need more sleep this time hopefully with the manpage attached. 

Alex


--fUYQa+Pmc3FrFX/N
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: attachment; filename="ss.8"
Content-Transfer-Encoding: quoted-printable

=2ETH SS 8
=2ESH NAME
ss \- another utility to investigate sockets
=2ESH SYNOPSIS
=2EB ss
=2ERI [ options ] " [ FILTER ]"
=2ESH DESCRIPTION
This manual page documents briefly the
=2EB ss
command.
=2EPP
\fBss\fP is another utility to investigate sockets. Functionally it is
NOT better than netstat combined with some perl/awk scripts and though it is
surely faster it is not enough to make it much better. :-) So, stop reading
this now and do not waste your time. Well, certainly, it proposes some
functionality, which current netstat is still not able to do, but surely wi=
ll
soon.
=2ESH OPTIONS
These programs follow the usual GNU command line syntax, with long
options starting with two dashes (`-').
A summary of options is included below.
=2ETP
=2EB \-h, \-\-help
Show summary of options.
=2ETP
=2EB \-V, \-\-version
Output version information.
=2ETP
=2EB \-n, \-\-numeric
Do now try to resolve service names.
=2ETP
=2EB \-r, \-\-resolve
Try to resolve numeric address/ports.
=2ETP
=2EB \-a, \-\-all
Display all sockets.
=2ETP
=2EB \-l, \-\-listening
Display listening sockets.
=2ETP
=2EB \-o, \-\-options
Show timer information.
=2ETP
=2EB \-e, \-\-extended
Show detailed socket information
=2ETP
=2EB \-m, \-\-memory
Show socket memory usage.
=2ETP
=2EB \-p, \-\-processes
Show process using socket.
=2ETP
=2EB \-i, \-\-info
Show internal TCP information.
=2ETP
=2EB \-s, \-\-summary
Print summary statistics. This option does not parse socket lists obtaining
summary from various sources. It is useful when amount of sockets is so huge
that parsing /proc/net/tcp is painful.
=2ETP
=2EB \-4, \-\-ipv4
Display only IP version 4 sockets (alias for -f inet).
=2ETP
=2EB \-6, \-\-ipv6
Display only IP version 6 sockets (alias for -f inet6).
=2ETP
=2EB \-0, \-\-packet
Display PACKET sockets.
=2ETP
=2EB \-t, \-\-tcp
Display only TCP sockets.
=2ETP
=2EB \-u, \-\-udp
Display only UDP sockets.
=2ETP
=2EB \-d, \-\-dccp
Display only DCCP sockets.
=2ETP
=2EB \-w, \-\-raw
Display only RAW sockets.
=2ETP
=2EB \-x, \-\-unix
Display only Unix domain sockets.
=2ETP
=2EB \-f FAMILY, \-\-family=3DFAMILY
Display sockets of type FAMILY.
Currently the following families are supported: unix, inet, inet6, link, ne=
tlink.
=2ETP
=2EB \-A QUERY, \-\-query=3DQUERY
List of socket tables to dump, separated by commas. The following identifie=
rs
are understood: all, inet, tcp, udp, raw, unix, packet, netlink, unix_dgram,
unix_stream, packet_raw, packet_dgram.
=2ETP
=2EB \-D FILE
Do not display anything, just dump raw information about TCP sockets to FIL=
E after applying filters. If FILE is - stdout is used.
=2ETP
=2EB \-F FILE, \-\-filter=3DFILE
Read filter information from FILE.
Each line of FILE is interpreted like single command line option. If FILE i=
s - stdin is used.
=2ETP
=2EB FILTER :=3D [ state TCP-STATE ] [ EXPRESSION ]
Please take a look at the official documentation (Debian package iproute-do=
c) for details regarding filters.
=2ESH USAGE EXAMPLES
=2ETP
=2EB ss -t -a
Display all TCP sockets.
=2ETP
=2EB ss -u -a
Display all UDP sockets.
=2ETP
=2EB ss -o state established '( dport =3D :ssh or sport =3D :ssh )'
Display all established ssh connections.
=2ETP
=2EB ss -x src \"/tmp/.X11-unix/*\"
Find all local processes connected to X server.
=2ETP
=2EB ss -o state fin-wait-1 '( sport =3D :http or sport =3D :https )' dst 1=
93.233.7/24
List all the tcp sockets in state FIN-WAIT-1 for our apache to network 193.=
233.7/24 and look at their timers.
=2ESH SEE ALSO
=2EBR ip (8),
=2EBR /usr/share/doc/iproute-doc/ss.html " (package iproute=ADdoc)"
=2ESH AUTHOR
ss was written by Alexey Kuznetosv, <kuznet@ms2.inr.ac.ru>.
=2EPP
This manual page was written by Michael Prokop <mika@grml.org>
for the Debian project (but may be used by others).

--fUYQa+Pmc3FrFX/N--
