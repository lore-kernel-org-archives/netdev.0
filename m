From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 10/10] net: remove SK_ROUTE_CAPS from meta ematch
Date: Thu, 14 Jul 2011 13:52:25 -0700 (PDT)
Message-ID: <20110714.135225.1309080335146524627.davem@davemloft.net>
References: <b06d1da00c5f333bb5d8d9f01aa306ff69b99df5.1310601401.git.mirq-linux@rere.qmqm.pl>
	<1310605166.2416.0.camel@mojatatu>
	<20110714205004.GC16759@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jhs@mojatatu.com, netdev@vger.kernel.org, shemminger@vyatta.com
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34107 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932160Ab1GNUx5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2011 16:53:57 -0400
In-Reply-To: <20110714205004.GC16759@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Thu, 14 Jul 2011 22:50:05 +0200

> On Wed, Jul 13, 2011 at 08:59:26PM -0400, jamal wrote:
>> On Thu, 2011-07-14 at 02:10 +0200, Micha=A9=A9 Miros=A9=A9aw wrote:
>> > Remove it, as it indirectly exposes netdev features. It's not used=
 in
>> > iproute2 (2.6.38) - is anything else using its interface?
>> Breaks user ABI.
>=20
> No iproute2 version uses it, its meaning have already changed several
> times in kernel history and it prevents improving the netdev features
> infrastructure. Note that other IDs are not changed - just this one i=
s
> turned into unsupported.

I totally agree.

We have to disconnect the layout and specific bit patterns in
netdev features from any userspace dependency.
