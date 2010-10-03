From: Alexander Zimmermann <alexander.zimmermann@comsys.rwth-aachen.de>
Subject: Fwd: [multipathtcp] Call for contribution to middlebox survey
Date: Sun, 03 Oct 2010 11:28:42 +0200
Message-ID: <D6F77554-EA69-40C0-A09C-C6EFF6572802@comsys.rwth-aachen.de>
References: <985BFFF5-B9DB-4F68-8837-24E434FD08AD@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg=pgp-sha1; boundary=Apple-Mail-5-700761144
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-2.ms.rz.RWTH-Aachen.DE ([134.130.7.73]:60243 "EHLO
	mta-2.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750878Ab0JCJ2p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Oct 2010 05:28:45 -0400
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-2.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0L9P00M1ZJNVIX50@mta-2.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Sun, 03 Oct 2010 11:28:43 +0200 (CEST)
Received: from [192.168.4.13] ([unknown] [77.109.116.240])
 by relay-auth-2.ms.rz.rwth-aachen.de
 (Sun Java(tm) System Messaging Server 7.0-3.01 64bit (built Dec  9 2008))
 with ESMTPA id <0L9P00H3XJNVMG20@relay-auth-2.ms.rz.rwth-aachen.de> for
 netdev@vger.kernel.org; Sun, 03 Oct 2010 11:28:43 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--Apple-Mail-5-700761144
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset=us-ascii

Hi folks,

the Michio Honda from IETF Multipath TCP WG needs some help...

Alex

Anfang der weitergeleiteten E-Mail:

> Von: Michio Honda <micchie@sfc.wide.ad.jp>
> Datum: 3. Oktober 2010 01:30:57 MESZ
> An: Multipath TCP Mailing List <multipathtcp@ietf.org>, =
<tcpm@ietf.org>
> Kopie: Mark Handley <m.handley@cs.ucl.ac.uk>
> Betreff: [multipathtcp] Call for contribution to middlebox survey
>=20
> Hi,=20
>=20
> We are surveying middleboxes affecting TCP in the Internet, and we'd =
like you to contribute to this work by running 1 python script at your =
available networks, because we want data of as many paths as possible.   =
=20
> This script generates test TCP traffic to a server node, and detects =
various middlebox behavior, for example, it detects how unknown TCP =
options are treated and if sequence number is rewritten. =20
>=20
> - Overview of script
> This generates test TCP traffic by using raw socket or pcap.=20
> Destinations of the test traffic are port 80, 443 and 34343 on =
vinson3.sfc.wide.ad.jp, which is located in Japan.=20
> The total amount of test traffic is approximately 90 connections (not =
parallel), and each of them uses approximately maximum 2048Byte.   =20
>=20
> - System requirement
> Our script works on Mac OSX 10.5 or 10.6, Linux (kernel 2.6) and =
FreeBSD (7.0 or higher).  This also requires python 2.5 or higher, and =
libpcap
> NOTE. if you try in a virtual machine on Windows, please connect the =
guest OS via not NAT but bridge.  =20
>=20
> How to run experiment is described below per-OS basis. =20
>=20
> After the experiment, you will find 3 log files (logxxxxxxxxx.txt) in =
the same directory as the experiment. =20
> Please send them to us (micchie@sfc.wide.ad.jp) and tell me your =
network information as much as you know (e.g., product name of the =
broadband router, ISP name, product name of firewall appliance etc...)=20=

> In addition, let us know if you have hesitation to open these =
information. =20
> This experiment doesn't collect traffic information other than those =
our script generated. =20
>=20
> ***** How to run the experiment (Mac OSX) *****
>=20
> 1. Filtering RST TCP segment from OS
> Execute a following command by root:
> ipfw add 101 deny tcp from any to vinson3.sfc.wide.ad.jp dst-port =
34343,80,443 tcpflags rst
>=20
> NOTE: if you are already running ipfw, please add equivalent rules
> After the experiment, you can revert by "ipfw delete 101"
>=20
> 2. Executing script
> Download script from =
http://www.micchie.net/software/tcpexposure/for_distrib.tar.gz, and =
decompress it to anywhere you like (e.g., tar xzf for_distrib.tar.gz by =
command line)
>=20
> In the for_distrib directory, execute a following command by root:
> sh run-bsd2.sh
> (This will take approximately 30 min.)
>=20
>=20
> ***** How to run the experiment (Linux) *****
>=20
> 1. Filtering RST TCP segment from OS
> Execute following command by root:
> /sbin/iptables -A OUTPUT -p tcp -d vinson3.sfc.wide.ad.jp --tcp-flags =
RST RST -m multiport --dports 34343,80,443 -j DROP
>=20
> NOTE: if you are already running iptables, please add equivalent rules
> After the experiment, you can revert by opposite commands - using -D =
instead of -A
>=20
> 2. Executing script
> Download script from =
http://www.micchie.net/software/tcpexposure/for_distrib.tar.gz, and =
decompress it to anywhere you like (e.g., tar xzf for_distrib.tar.gz)
>=20
> In the for_distrib directory, execute a following command by root:
> sh run-linux2.sh
> (This will take approximately 30 min.)
>=20
>=20
> ***** How to run the script (FreeBSD) *****
>=20
> 1. Filtering RST TCP segment from OS  =20
> If you are using neither ipfw nor pf:=20
> Load pf kernel module with a following command by root:
> kldload /boot/kernel/pf.ko
>=20
> Add following 2 lines to /etc/pf.conf (please replace IFNAME to your =
outgoing interface name (e.g., em0):
> pass out all
> block out quick on IFNAME proto tcp to vinson3.sfc.wide.ad.jp port =
{34343,80,443} flags R/R
>=20
> Execute following command by root:
> pfctl -e -f /etc/pf.conf
>=20
> If you are already running pf, please add equivalent rules
> After the experiment, you can revert settings by  cleaning up =
/etc/pf.conf and executing "pfctl -d" by root
>=20
> If you are already using ipfw:
>  Please add a following rule to ipfw configuration:
>  deny tcp from any to vinson3.sfc.wide.ad.jp dst-port 34343,80,443 =
tcpflags rst
>=20
> 2. Executing script
> Download script from =
http://www.micchie.net/software/tcpexposure/for_distrib.tar.gz, and =
decompress it to anywhere you like (e.g., tar xzf for_distrib.tar.gz)
>=20
> In the for_distrib directory, execute a following command by root:
> sh run-bsd2.sh
> (This will take approximately 30 min.)
>=20
>=20
> Best regards,
> - Michio
>=20
> _______________________________________________
> multipathtcp mailing list
> multipathtcp@ietf.org
> https://www.ietf.org/mailman/listinfo/multipathtcp

//
// Dipl.-Inform. Alexander Zimmermann
// Department of Computer Science, Informatik 4
// RWTH Aachen University
// Ahornstr. 55, 52056 Aachen, Germany
// phone: (49-241) 80-21422, fax: (49-241) 80-22222
// email: zimmermann@cs.rwth-aachen.de
// web: http://www.umic-mesh.net
//


--Apple-Mail-5-700761144
content-type: application/pgp-signature; x-mac-type=70674453;
	name=PGP.sig
content-description: Signierter Teil der Nachricht
content-disposition: inline; filename=PGP.sig
content-transfer-encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (Darwin)

iEYEARECAAYFAkyoTMoACgkQdyiq39b9uS6x6QCg34yy6mf0Hll0wg/Z5QVS4NDN
n+EAoPydpnsBmtXe29FLToIrbgNujVKX
=O/zr
-----END PGP SIGNATURE-----

--Apple-Mail-5-700761144--
