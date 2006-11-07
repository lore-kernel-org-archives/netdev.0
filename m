From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: Zero checksum in netconsole/netdump packets
Date: Tue, 7 Nov 2006 12:35:06 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0611071232450.10769@bizon.gios.gov.pl>
References: <454FC80B.9090001@redhat.com> <200611071009.02424@strip-the-willow>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-237262693-1162899306=:10769"
Cc: Chris Lalancette <clalance@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:16594 "EHLO
	bizon.gios.gov.pl") by vger.kernel.org with ESMTP id S1754197AbWKGLfR
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Nov 2006 06:35:17 -0500
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>
In-Reply-To: <200611071009.02424@strip-the-willow>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-237262693-1162899306=:10769
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Tue, 7 Nov 2006, Gerrit Renker wrote:

> Quoting Chris Lalancette:
> |  Hello,
> |       I realized that all of the packets that go from the crashing mach=
ine to the netdump server have a zero checksum.
> <snip>
> |       Assuming that this is just an oversight, attached is a simple pat=
ch to compute the UDP checksum in netpoll_send_udp.
> |
> |  Signed-off-by: Chris Lalancette <clalance@redhat.com>
> |
> RFC 768 allows to not compute the checksum by leaving uh->check at 0 - he=
nce it is not illegal.

BTW: leaving UDP checksum at 0 is only valid for IPv4, with IPv6 we _have=
=20
to_ compute a checksum.

Best regards,

 =09=09=09Krzysztof Ol=EAdzki
---187430788-237262693-1162899306=:10769--
