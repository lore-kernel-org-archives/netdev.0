From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 0/2] NET: Accurate packet scheduling for ATM/ADSL
Date: Wed, 21 Jun 2006 14:54:42 +0200
Message-ID: <44994192.5050807@trash.net>
References: <1150278004.26181.35.camel@localhost.localdomain> <1150815544.5270.82.camel@jzny2> <4498114F.8090700@trash.net> <200606211421.05606.kyf@arterm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:2733 "EHLO stinky.trash.net")
	by vger.kernel.org with ESMTP id S932092AbWFUMyo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2006 08:54:44 -0400
To: Krzysztof Matusik <kyf@arterm.pl>
In-Reply-To: <200606211421.05606.kyf@arterm.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Krzysztof Matusik wrote:
> Dnia wtorek, 20 czerwca 2006 17:16, Patrick McHardy napisa=C5=82:
>=20
>>The code wouldn't be very complicated, it just adds some overhead. If
>>you do something like I described in my previous mail the overhead fo=
r
>>people not using it would be an additional pointer test before readin=
g
>>skb->len. I guess we could also make it a compile time option.
>>I personally think this is something that really improves our quality
>>of implementation, after all, its "wire" resources qdiscs are meant
>>to manage.
>=20
>=20
> I'd love to see this one implemented. I'm using HFSC more than a year=
 and it=20
> never provides proper QoS on ATM/ADSL links; low delays can never be =
achieved=20
> even with significant throttling below the h/w link bandwidth.

Mhh .. I trust you picked a proper clocksource and timer frequency?

> This would help a lot regarding the amount of adsl users but on the o=
ther=20
> hand- there's not many HFSC implementations in real-life I guess (use=
rs seem=20
> to be afraid of it's 'complexity').=20
> This idea doesn't seem look dirty- is there a chance to implement it =
in the=20
> kernel and iproute?

I hacked up a patch yesterday. I want to do a bit more testing before
posting it, but its hard to really test the effectiveness because even
without this patch my DSL line already delivers higher throughput and
much better delay than it should (its a throttled SDSL line sold as
ADSL). I'll try to do some testing on an ethernet link now.
