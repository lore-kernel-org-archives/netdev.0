From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Connection tracking and vlan
Date: Fri, 30 Oct 2009 16:31:50 +0100
Message-ID: <4AEB06E6.6020206@gmail.com>
References: <20091030152054.GA7936@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Adayadil Thomas <adayadil.thomas@gmail.com>,
	netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:38161 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932427AbZJ3Pbx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 11:31:53 -0400
In-Reply-To: <20091030152054.GA7936@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu a =E9crit :
> Adayadil Thomas <adayadil.thomas@gmail.com> wrote:
>> If two connections have same 5 tuple, src ip, dst ip, src port, dst
>> port, protocol(tcp/udp)
>> but on different vlans (different vlan id), does the conntrack separ=
ate these ?
>=20
> Probably not.  Patrick, can you confirm this?
>=20

Very strange, this question about vlan looks like discussion we had
yesterday (or the day before...) about interfaces (versus packet defrag=
mentation)

"IP conntracking" is about IP, and [V]LAN doesnt matter at all at this =
protocol level.

Same thing if you have two interfaces, eth0 & eth1 : IP conntrack tuple=
s dont
include interface name/index

