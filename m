From: Wolfgang Walter <linux@stwm.de>
Subject: Re: [PATCH] ipv6: Fix udp checksums with raw sockets
Date: Fri, 15 May 2015 11:37:14 +0200
Message-ID: <4682386.1vFt617rtG@h2o.as.studentenwerk.mhn.de>
References: <1431650048-16189-1-git-send-email-vyasevic@redhat.com> <20150514.222732.1628575030241731130.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, vyasevic@redhat.com
To: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailin.studentenwerk.mhn.de ([141.84.225.229]:53322 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753021AbbEOJhS convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 May 2015 05:37:18 -0400
In-Reply-To: <20150514.222732.1628575030241731130.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Donnerstag, 14. Mai 2015, 22:27:32 schrieben Sie:
> From: Vladislav Yasevich <vyasevich@gmail.com>
> Date: Thu, 14 May 2015 20:34:08 -0400
>=20
> > It was reported that trancerout6 would cause
> > a kernel to crash when trying to compute checksums
> > on raw UDP packets.  The cause was the check in
> > __ip6_append_data that would attempt to use
> > partial checksums on the packet.  However,
> > raw sockets do not initialize partial checksum
> > fields so partial checksums can't be used.
> >=20
> > Solve this the same way IPv4 does it.  raw sockets
> > pass transhdrlen value of 0 to ip_append_data which
> > causes the checksum to be computed in software.  Use
> > the same check in ip6_append_data (check transhdrlen).
> >=20
> > Reported-by: Wolfgang Walter <linux@stwm.de>
> > CC: Wolfgang Walter <linux@stwm.de>
> > CC: Eric Dumazet <eric.dumazet@gmail.com>
> > Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
>=20
> Applied.... This seems like -stable material?  If so, how far
> back?

starting with 4.0

Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
