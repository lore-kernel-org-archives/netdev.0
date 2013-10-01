From: Wolfgang Walter <linux@stwm.de>
Subject: Re: Big performance loss from 3.4.63 to 3.10.13 when routing ipv4
Date: Tue, 01 Oct 2013 21:44:10 +0200
Message-ID: <3185382.JVjo9Kr7dt@h2o.as.studentenwerk.mhn.de>
References: <3244031.uQGDddGTLF@h2o.as.studentenwerk.mhn.de> <524B1B1D.3050304@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dresden.studentenwerk.mhn.de ([141.84.225.229]:46379 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750881Ab3JAToM convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Oct 2013 15:44:12 -0400
In-Reply-To: <524B1B1D.3050304@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Dienstag, 1. Oktober 2013, 14:57:33 schrieb Brian Haley:
> On 10/01/2013 12:39 PM, Wolfgang Walter wrote:
> > Hello,
> >=20
> > I tried to upgrade one of our routers to 3.10.13 from 3.4.63 and I =
see a
> > dramatic performance loss. I tried 3.11.2 and it is still there.
> >=20
> > *** Symptoms:
> >=20
> > All network traffic over the router become slow and sluggish. If on=
e pings
> > the router there is a packet loss. After about 2 minutes the traffi=
c
> > completely stalls for about 1 minute. Then it works again as in the
> > beginning to then stall again. And so on.
> >=20
> > This happens even with rather moderate traffic. While still routing=
 the
> > CPU
> > utilization is higher than it is with 3.4.63 but only moderately.
> >=20
> > When it stalls no network traffic seems possible (but to loopback).=
 If one
> > tries to ping from the router any target (even if it is on a interf=
ace
> > with no>=20
> > traffic at all) one gets:
> > 	ping: sendmsg: No buffer space available
>=20
> dmesg show anything?  I've seen this happen when the neighbour table =
is
> full, but that's not a typical occurence.
>=20

Nothing is logged.

No, the neighbour table is not full. At least is does not contain more =
entries=20
then usually and not more then under 3.4 (maybe 100 or so).

I also checked the number of entries in the conntrack table and things =
like=20
that: all normal.

Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
