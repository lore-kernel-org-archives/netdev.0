From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net_sched: sch_mqprio: dont leak kernel
 memory
Date: Wed, 26 Jan 2011 18:49:50 +0100
Message-ID: <1296064190.2899.88.camel@edumazet-laptop>
References: <1296062517.2899.86.camel@edumazet-laptop>
	 <1296063823.6115.37.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	John Fastabend <john.r.fastabend@intel.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:39727 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753548Ab1AZRtz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jan 2011 12:49:55 -0500
Received: by wwi17 with SMTP id 17so5483314wwi.1
        for <netdev@vger.kernel.org>; Wed, 26 Jan 2011 09:49:54 -0800 (PST)
In-Reply-To: <1296063823.6115.37.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 26 janvier 2011 =C3=A0 09:43 -0800, Joe Perches a =C3=A9cri=
t :

> I think the best style to use memset so that any
> possible struct padding is guaranteed to be zeroed.
>=20
>=20

We use the { 0 } style in net/sched, and there is no padding in this
structure, I checked this point.



