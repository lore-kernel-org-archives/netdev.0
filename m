From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4/ipv6: check hop limit field on input
Date: Mon, 01 Jun 2009 22:43:30 -0700 (PDT)
Message-ID: <20090601.224330.267938162.davem@davemloft.net>
References: <4A23F027.3060907@dev.6wind.com>
	<20090601.190430.80366622.davem@davemloft.net>
	<4A24B920.2010605@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nicolas.dichtel@dev.6wind.com, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42911
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755361AbZFBFna convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jun 2009 01:43:30 -0400
In-Reply-To: <4A24B920.2010605@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 02 Jun 2009 07:31:12 +0200

> David Miller a =E9crit :
>> From: Nicolas Dichtel <nicolas.dichtel@dev.6wind.com>
>> Date: Mon, 01 Jun 2009 17:13:43 +0200
>>=20
>>> RFC indicates that a router must drop the packet if this field is 0=
=2E
>>=20
>> It only must do this when executing the forwarding function.  It's a=
n
>> egress check, not an ingress one.
>>=20
>> I'm not applying this patch, it can even break some applications
>> out there that use a TTL of zero intentionally to keep traffic
>> only on a local subnet.
>=20
> I wonder if we then should allow setting ttl to zero. I had to patch
> my kernel to allow ping to do this...
>=20
> I'll check RFC when time permits.

Eric, notice how I mentioned in my other reply to this thread
"multicast" applications, which use mc_ttl which we allow to be set to
zero.
