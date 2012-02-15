From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.0: unexpected route cache entry for wrong segment?
Date: Wed, 15 Feb 2012 13:46:47 +0100
Message-ID: <1329310007.2437.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4F33FC0E.4020701@msgid.tls.msk.ru>
	 <1328809519.6099.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4F341283.1020904@msgid.tls.msk.ru> <4F3BA0BD.9010501@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Michael Tokarev <mjt@tls.msk.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:58627 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753837Ab2BOMqu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 07:46:50 -0500
Received: by wics10 with SMTP id s10so484821wic.19
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2012 04:46:49 -0800 (PST)
In-Reply-To: <4F3BA0BD.9010501@msgid.tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 15 f=C3=A9vrier 2012 =C3=A0 16:10 +0400, Michael Tokarev a =
=C3=A9crit :

> David, any progress with these?
>=20
> 7cc9150ebe8ec06cafea9f1c10d92ddacf88d8ae "route: fix ICMP redirect va=
lidation"
> applies correctly to 3.0, but 9cc20b268a5a14f5e57b8ad405a83513ab0d78d=
c
> "ipv4: fix redirect handling" does not, due to some changes in-betwee=
n,
> but these should be easy to sort out.  Should I perhaps refresh this
> patch myself?  It should be doable, I think.

I totally screwed up when I said that, I was mixing things.

Can you reproduce this problem with latest 3.0.21 ?
