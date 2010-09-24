From: Ulrich Weber <uweber@astaro.com>
Subject: Re: [RFC PATCH] dont create cached routes from ARP requests
Date: Fri, 24 Sep 2010 17:43:43 +0200
Message-ID: <4C9CC72F.2080102@astaro.com>
References: <20100922162209.GA10281@babylon>	 <20100922.203442.233700254.davem@davemloft.net>	 <20100923144708.GA8037@babylon> <1285254302.2509.47.camel@edumazet-laptop>	 <4C9CBCFC.6080300@gmail.com>  <1285342083.2503.252.camel@edumazet-laptop> <1285342497.2503.260.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ulrich Weber <ulrich.weber@googlemail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-74.dex002.intermedia.net ([64.78.20.104]:50346 "EHLO
	DHOST002-74.dex002.intermedia.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932173Ab0IXPnt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Sep 2010 11:43:49 -0400
In-Reply-To: <1285342497.2503.260.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

/proc/sys/net/ipv4/conf/all/arp_accept:0
/proc/sys/net/ipv4/conf/default/arp_accept:0
/proc/sys/net/ipv4/conf/lo/arp_accept:0
/proc/sys/net/ipv4/conf/eth0/arp_accept:0
/proc/sys/net/ipv4/conf/dummy0/arp_accept:0

On 09/24/2010 05:34 PM, Eric Dumazet wrote:
> Le vendredi 24 septembre 2010 =C3=A0 17:28 +0200, Eric Dumazet a =C3=A9=
crit :
>=20
>> What are the packets you receive ? A flood of ARP answers ?
>>
>> a "tcpdump -X" of a few packets would help to understand.
>>
>>
>=20
>=20
> Also please report=20
>=20
> grep . `find /proc/sys -name arp_accept`
>=20
>=20
>=20


--=20
Ulrich Weber | uweber@astaro.com | Software Engineer
Astaro GmbH & Co. KG | www.astaro.com | Phone +49-721-25516-0 | Fax =E2=
=80=93200
An der RaumFabrik 33a | 76227 Karlsruhe | Germany
