From: Shan Wei <shanwei88@gmail.com>
Subject: Re: [PATCH] net: fix compile error of leaking kmemleak.h header
Date: Thu, 19 Apr 2012 12:08:15 +0800
Message-ID: <4F8F8FAF.9020509@gmail.com>
References: <4F8F8F1A.6020000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: majianpeng@gmail.com, Eric Dumazet <eric.dumazet@gmail.com>,
	NetDev <netdev@vger.kernel.org>,
	davidshan <davidshan@tencent.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f52.google.com ([209.85.210.52]:43398 "EHLO
	mail-pz0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1749667Ab2DSEH3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 00:07:29 -0400
Received: by dake40 with SMTP id e40so10781384dak.11
        for <netdev@vger.kernel.org>; Wed, 18 Apr 2012 21:07:29 -0700 (PDT)
In-Reply-To: <4F8F8F1A.6020000@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shan Wei said, at 2012/4/19 12:05:

> From: Shan Wei <davidshan@tencent.com>
>=20
> net/core/sysctl_net_core.c: In function =91sysctl_core_init=92:
> net/core/sysctl_net_core.c:259: error: implicit declaration of functi=
on =91kmemleak_not_leak=92
>=20
> with same error in net/ipv4/route.c


This is for net-next.....
