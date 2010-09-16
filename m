From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next2.6] ipv4: ip_ptr cleanups
Date: Thu, 16 Sep 2010 07:26:08 +0200
Message-ID: <1284614768.2462.87.camel@edumazet-laptop>
References: <1284559471.2495.147.camel@edumazet-laptop>
	 <20100915.214335.135526473.davem@davemloft.net>
	 <20100915.220522.25138138.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linville@tuxdriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:54074 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751238Ab0IPF0o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Sep 2010 01:26:44 -0400
Received: by wwd20 with SMTP id 20so192727wwd.1
        for <netdev@vger.kernel.org>; Wed, 15 Sep 2010 22:26:42 -0700 (PDT)
In-Reply-To: <20100915.220522.25138138.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 15 septembre 2010 =C3=A0 22:05 -0700, David Miller a =C3=A9=
crit :

> Eric this introduces a build failure when lockdep or RCU checking
> is enabled.
>=20
> The problem is that inetdevice.h now references lockdep_rtnl_is_held(=
)
> but does not include rtnetlink.h
>=20
> I'll simply ammend your commit with that header include added.
>=20
> Just FYI...

Gahh, you're right, thanks !


