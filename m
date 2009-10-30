From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Connection tracking and vlan
Date: Fri, 30 Oct 2009 17:19:30 +0100
Message-ID: <4AEB1212.6010905@gmail.com>
References: <20091030152054.GA7936@gondor.apana.org.au> <4AEB06E6.6020206@gmail.com> <20091030154639.GA8197@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Adayadil Thomas <adayadil.thomas@gmail.com>,
	netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:52813 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932473AbZJ3QUI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 12:20:08 -0400
In-Reply-To: <20091030154639.GA8197@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu a =E9crit :
> On Fri, Oct 30, 2009 at 04:31:50PM +0100, Eric Dumazet wrote:
>> Same thing if you have two interfaces, eth0 & eth1 : IP conntrack tu=
ples dont
>> include interface name/index
>=20
> Indeed, but imagine what happens when eth0 is the LAN and eth1 is
> the wild wild Internet.  Do you really want their packets to mix?
>=20

No, Abayadi needs firewall rules (or RPF), before entering conntrack.

Allowing spoofed packets to come from wild Internet would be...
interesting in many aspects.

And since some setups use several links to LAN, several links to
Internet, its user policy decisions.

