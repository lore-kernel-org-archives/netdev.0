From: Patrick McHardy <kaber@trash.net>
Subject: Re: Connection tracking and vlan
Date: Fri, 30 Oct 2009 17:27:10 +0100
Message-ID: <4AEB13DE.2030200@trash.net>
References: <20091030152054.GA7936@gondor.apana.org.au> <4AEB06E6.6020206@gmail.com> <20091030154639.GA8197@gondor.apana.org.au> <4AEB1212.6010905@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Adayadil Thomas <adayadil.thomas@gmail.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48219 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932584AbZJ3Q1N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 12:27:13 -0400
In-Reply-To: <4AEB1212.6010905@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Herbert Xu a =E9crit :
>> On Fri, Oct 30, 2009 at 04:31:50PM +0100, Eric Dumazet wrote:
>>> Same thing if you have two interfaces, eth0 & eth1 : IP conntrack t=
uples dont
>>> include interface name/index
>> Indeed, but imagine what happens when eth0 is the LAN and eth1 is
>> the wild wild Internet.  Do you really want their packets to mix?
>>
>=20
> No, Abayadi needs firewall rules (or RPF), before entering conntrack.
>=20
> Allowing spoofed packets to come from wild Internet would be...
> interesting in many aspects.
>=20
> And since some setups use several links to LAN, several links to
> Internet, its user policy decisions.

Correct, users need to take care of this manually.
