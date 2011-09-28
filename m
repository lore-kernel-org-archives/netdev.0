From: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Subject: Question about reply to a datagram sent to a Subnet-Router anycast address
Date: Wed, 28 Sep 2011 07:13:22 -0700 (PDT)
Message-ID: <1317219202.22987.YahooMailClassic@web126017.mail.ne1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm24.bullet.mail.ne1.yahoo.com ([98.138.90.87]:24880 "HELO
	nm24.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754146Ab1I1OUE convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Sep 2011 10:20:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

I try to ping some routers on one of their Subnet-Router anycast addres=
ses (SRAA).
(http://tools.ietf.org/html/rfc4291#section-2.6.1)

A Linux kernel 3.0 in IPv6 forwarding mode reply with an unicast source=
 address (same subnet prefix).
An Alcatel router reply with the SRAA as source address.

The RFC 4291 removed the restrictions on using IPv6 anycast addresses, =
so a SRAA may be used as a source address, in a reply.

In the following draft, we have a rationale for the removal of restrict=
ions regarding anycast as source address in RFC 4291 :
(http://tools.ietf.org/html/draft-jabley-v6-anycast-clarify-00#section-=
3.1)
"3.1 Anycast Source Addresses
=A0=A0=A0For many conventional services to be distributed using anycast=
, it is
=A0=A0=A0necessary for reply datagrams sent from servers to clients to =
be
=A0=A0=A0sourced from the same address that was used as the destination=
 in
=A0=A0=A0request datagrams sent from clients to servers.=A0 When such a=
 service
=A0=A0=A0is distributed using anycast, the destination address used in =
request
=A0=A0=A0datagrams is necessarily an anycast address; corresponding rep=
ly
=A0=A0=A0packets must therefore use the same anycast address as their s=
ource
=A0=A0=A0address.
=A0=A0=A0Being able to use an anycast address as the source address in =
an IPv6
=A0=A0=A0datagram is a prerequisite for the distribution of many servic=
es
=A0=A0=A0using anycast over IPv6."

A SRAA is a special case of anycast address.

Is there a way to setup the Linux kernel to behave like Alcatel router,=
 replying with the SRAA as source address ?

If not, why not update the behaviour of the Linux kernel to configurabl=
e ?

Please let me know your feedback.

Thanks,
=46rancois-Xavier Le Bail
