From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ip_gre: fix fallback tunnel setup
Date: Thu, 28 Oct 2010 21:34:36 +0200
Message-ID: <1288294476.2711.21.camel@edumazet-laptop>
References: <1288283634.11523.20.camel@edumazet-laptop>
	 <20101028.102917.246527148.davem@davemloft.net>
	 <1288291138.2711.0.camel@edumazet-laptop>
	 <20101028.114102.112602886.davem@davemloft.net>
	 <1288291679.2711.1.camel@edumazet-laptop>
	 <1288293079.2711.19.camel@edumazet-laptop> <4CC9CF06.1090806@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:39907 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758152Ab0J1Tel (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 15:34:41 -0400
Received: by wyf28 with SMTP id 28so2309932wyf.19
        for <netdev@vger.kernel.org>; Thu, 28 Oct 2010 12:34:39 -0700 (PDT)
In-Reply-To: <4CC9CF06.1090806@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 28 octobre 2010 =C3=A0 23:29 +0400, Pavel Emelyanov a =C3=A9cr=
it :

> Indeed. I missed the fact, that the gre driver uses ndo_init for
> all devices including the fb one :(
>=20
> Acked-by: Pavel Emelyanov <xemul@openvz.org>

Well, I discovered this right now, it was not that obvious, maybe we
should use similar setup for all fb tunnels as well...

Thanks !


