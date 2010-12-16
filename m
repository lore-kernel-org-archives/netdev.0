From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] filter: optimize accesses to ancillary
 data
Date: Thu, 16 Dec 2010 08:08:13 +0100
Message-ID: <1292483293.2603.58.camel@edumazet-laptop>
References: <1292478328.2603.56.camel@edumazet-laptop>
	 <AANLkTikFqwsze0xZ6+aAhzpJJzng6pWHueimpSkWQNeg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:60119 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751364Ab0LPHIS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 02:08:18 -0500
Received: by wwa36 with SMTP id 36so2110694wwa.1
        for <netdev@vger.kernel.org>; Wed, 15 Dec 2010 23:08:17 -0800 (PST)
In-Reply-To: <AANLkTikFqwsze0xZ6+aAhzpJJzng6pWHueimpSkWQNeg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 16 d=C3=A9cembre 2010 =C3=A0 14:34 +0800, Changli Gao a =C3=A9=
crit :

> A default case should be handled as you remove the k > SKF_AD_OFF fro=
m
> load_pointer().
>=20

No, __load_pointer will return NULL in this case.



