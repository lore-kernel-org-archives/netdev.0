From: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Subject: [RFC] The Linux kernel IPv6 stack don't follow the RFC 4942 recommendation
Date: Fri, 4 Nov 2011 07:46:28 -0700 (PDT)
Message-ID: <1320417988.69298.YahooMailNeo@web126013.mail.ne1.yahoo.com>
Reply-To: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm36-vm7.bullet.mail.ne1.yahoo.com ([98.138.229.119]:20959 "HELO
	nm36-vm7.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751443Ab1KDOwr convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Nov 2011 10:52:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I do some tests on a Linux 3.0 kernel with IPv6 forwarding mode enabled=
=2E

When I ping (ICMPv6 echo request) on one of its Subnet-Router anycast a=
ddresses
(SRAA, http://tools.ietf.org/html/rfc4291#section-2.6.1),
the Linux kernel reply with an unicast source address, not the anycast =
one.

When I send an IPv6 UDP packet to a server on Linux on one of its SRAA,
the Linux kernel build a reply with an unicast source address, not the =
anycast one.

The RFC 4942 states (http://tools.ietf.org/html/rfc4942#section-2.1.6) =
:
2.1.6. Anycast Traffic Identification and Security
[. . .]
=A0  To avoid exposing knowledge about the internal structure of the
=A0  network, it is recommended that anycast servers now take advantage=
 of
=A0  the ability to return responses with the anycast address as the
=A0  source address if possible.

Also, If the source address of reply differs from destination address o=
f the request, many applications are broken.
Please let me know your feedback.


Thanks,
=46rancois-Xavier Le Bail
