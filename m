From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net_sched: sch_mqprio: dont leak kernel
 memory
Date: Wed, 26 Jan 2011 21:25:55 +0100
Message-ID: <1296073555.2631.6.camel@edumazet-laptop>
References: <1296062517.2899.86.camel@edumazet-laptop>
	 <1296063823.6115.37.camel@Joe-Laptop>
	 <20110126.115530.226756606.davem@davemloft.net>
	 <1296073390.2631.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: joe@perches.com, netdev@vger.kernel.org, john.r.fastabend@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:45909 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753467Ab1AZUZ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jan 2011 15:25:59 -0500
Received: by wwa36 with SMTP id 36so1399004wwa.1
        for <netdev@vger.kernel.org>; Wed, 26 Jan 2011 12:25:58 -0800 (PST)
In-Reply-To: <1296073390.2631.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 26 janvier 2011 =C3=A0 21:23 +0100, Eric Dumazet a =C3=A9cr=
it :

> I am perfectly aware of this ugly memset() style some people prefer, =
and
> 5 % of the time they swap 2nd and 3rd param.
>=20
> Two patches instead of one ;)
>=20

One random example of memset() troubles :=20

commit fe10ae53384e48c51996941b7720ee16995cbcb7
fixed by commit 5b919f833d9d60588d026ad82d17f17e8872c7a9



