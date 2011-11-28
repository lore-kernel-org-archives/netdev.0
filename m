From: Ulrich Weber <Ulrich.Weber@Sophos.com>
Subject: Re: [RFC PATCH 00/18] netfilter: IPv6 NAT
Date: Mon, 28 Nov 2011 20:25:48 +0000
Message-ID: <CAF9AA63.1622%ulrich.weber@sophos.com>
References: <4ED3C174.9030302@earthlink.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "sclark46@earthlink.net" <sclark46@earthlink.net>,
	"kaber@trash.net" <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4ED3C174.9030302@earthlink.net>
Content-Language: de-DE
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 28.11.11 18:14 schrieb "Stephen Clark" unter <sclark46@earthlink.net=
>:
=20
>Probabably a dumb question but are these patches for natting ipv6 to
>ipv6 or ipv4 to ipv6?

These patches are for natting IPv6 addresses behind whole IPv6 subnets
or just behind one IPv6 address.

This is useful for multiple Internet uplinks, where you want full contr=
ol
on the router what connections are sent over which interface. Or its qu=
ite
easy to setup Load Balancing rules or create a DMZ. There a lots of use
cases=8A


If you are looking for IPv4->IPv6 or IPv6->IPv4, there are multiple
implementations. Two examples:

IPv6->IPv4:

http://ecdysis.viagenie.ca

IPv4->IPv6:
http://www.ivi2.org


Best regards
 Ulrich

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
