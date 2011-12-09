From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP fast retransmit
Date: Fri, 09 Dec 2011 15:43:31 +0100
Message-ID: <1323441811.2336.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <2D9E1426-D432-4D08-BF28-FD2615AAEDBA@mpi-bpc.mpg.de>
	 <1322239016.5793.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <C2C333F1-98FD-41FB-9CFA-EDE9F363CABF@mpi-bpc.mpg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Esztermann, Ansgar" <Ansgar.Esztermann@mpi-bpc.mpg.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:39546 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754192Ab1LIOng (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2011 09:43:36 -0500
Received: by lagp5 with SMTP id p5so1156928lag.19
        for <netdev@vger.kernel.org>; Fri, 09 Dec 2011 06:43:34 -0800 (PST)
In-Reply-To: <C2C333F1-98FD-41FB-9CFA-EDE9F363CABF@mpi-bpc.mpg.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 09 d=C3=A9cembre 2011 =C3=A0 14:34 +0100, Esztermann, Ansga=
r a =C3=A9crit :
> On Nov 25, 2011, at 17:36 , Eric Dumazet wrote:
>=20
> > Could you send a sample pcap of such problem, but please include fu=
ll
> > tcp sesssion, from the first SYN packet, up to packets following
> > restransmits.
>=20
> OK, I've got a dump now. It is rather large (>300MB), so it's probabl=
y not a good idea to send it to the list. Instead, you can find it here=
:
> http://wwwuser.gwdg.de/~aeszter/tcpstream.pcap
>=20
> The capture has been taken in the sender, 10.208.9.87, with a capture=
 filter on the receiver's IP address. OS is:
> % uname -a
> Linux mwolf 2.6.37.6-0.9-default #1 SMP 2011-10-19 22:33:27 +0200 x86=
_64 x86_64 x86_64 GNU/Linux
>=20
> The first "strange" retransmission is in frame 166859, following ACKs=
 in frames 166849 .. 166858.=20
>=20
> If I can do anything to reduce the amount of data, I will of course d=
o so.
>=20
> > A diff of "netstat -s" taken before your session and after your ses=
sion
> > on receiver would help too, if receiver is not a loaded machine of
> > course.
>=20
> Attached.
>=20
> Thanks a lot,
>=20
> A.
>=20

It seems you have a lot of packet reorders.

Are you using multipath or some channel bonding ?
