From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Re[2]: [Bugme-new] [Bug 16568] New: Regression and
 incompatibility with Windows SP2-SP3-Vista TCP stack causing lost
 connections
Date: Thu, 12 Aug 2010 19:18:19 +0200
Message-ID: <1281633499.2494.90.camel@edumazet-laptop>
References: <bug-16568-10286@https.bugzilla.kernel.org/>
	 <20100812074041.cf62b793.akpm@linux-foundation.org>
	 <1281625773.2494.38.camel@edumazet-laptop>
	 <68743058.20100812194607@ucoz.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Yuriy <yuriy@ucoz.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:33763 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752969Ab0HLRSY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Aug 2010 13:18:24 -0400
Received: by eya25 with SMTP id 25so814589eya.19
        for <netdev@vger.kernel.org>; Thu, 12 Aug 2010 10:18:23 -0700 (PDT)
In-Reply-To: <68743058.20100812194607@ucoz.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 12 ao=C3=BBt 2010 =C3=A0 19:46 +0300, Yuriy a =C3=A9crit :

> Thanks for reply.
>=20
> Main idea that i wanted to say is just to document this feature appro=
priately as internet is full of recommendations to enable it.=20
> Just few words like "do not used it on public servers" would be much =
better than now.

Sure, but we dont maintain nor correct the recommandations found on
various Internet pages ;)

BTW, a google search on "tcp_tw_recycle" gives many results on problems
with this setting, not improvements.

Also, many "recommandations" found on Internet suggest to disable
tcp_timestamps, only because it adds 12 bytes to TCP header.

Apparently you chose to follow the tcp_tw_recycle=3D1 recommandation, n=
ot
the tcp_timestamps=3D0 one ;)



