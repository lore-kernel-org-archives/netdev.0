From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] macvlan: lockless tx path
Date: Thu, 11 Nov 2010 19:02:52 +0100
Message-ID: <1289498572.17691.1599.camel@edumazet-laptop>
References: <1289403709.2860.216.camel@edumazet-laptop>
	 <4CDAD8C8.20807@candelatech.com>
	 <1289411027.2860.248.camel@edumazet-laptop>
	 <4CDADC17.6070506@candelatech.com>
	 <1289413120.2469.12.camel@edumazet-laptop>
	 <4CDAE713.7020309@candelatech.com>
	 <1289421187.2469.127.camel@edumazet-laptop> <4CDB1021.507@candelatech.com>
	 <1289427705.17691.52.camel@edumazet-laptop>
	 <4CDB226A.8080903@candelatech.com>
	 <1289432184.17691.141.camel@edumazet-laptop>
	 <4CDB2EBC.2090905@candelatech.com>
	 <1289459012.17691.1001.camel@edumazet-laptop>
	 <4CDC1C9A.3070102@candelatech.com>
	 <1289494618.17691.1498.camel@edumazet-laptop>
	 <4CDC25F5.7010501@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:48359 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752709Ab0KKSC5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 13:02:57 -0500
Received: by wwb34 with SMTP id 34so136411wwb.1
        for <netdev@vger.kernel.org>; Thu, 11 Nov 2010 10:02:55 -0800 (PST)
In-Reply-To: <4CDC25F5.7010501@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 11 novembre 2010 =C3=A0 09:20 -0800, Ben Greear a =C3=A9crit :

> I've shown you my algorithm that requires one to know the counter
> width, and in response you offered on that will work with 32 OR 64 bi=
ts,
> as long as you make some assumptions.
>=20
> If you have an algorithm that can properly deal with wrapped counters=
 of
> arbitrary bits, then post it.
>=20

Its only a generalization of RRD algo

No rocket science I am afraid.

You can try all the numbers in `seq 32 64` in this order, to get a
generic algo.

If you can certify all your devices are 32 or 64, then the RRD method i=
s
OK.



