From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] rps: make distributing packets fairly among all the
 online CPUs default
Date: Tue, 23 Mar 2010 14:06:20 +0100
Message-ID: <1269349580.2983.113.camel@edumazet-laptop>
References: <4BA85EA2.1090304@gmail.com>
	 <1269329250.3043.19.camel@edumazet-laptop>
	 <412e6f7f1003230303l69fc142ey1581fff4c3e749be@mail.gmail.com>
	 <1269344306.2983.16.camel@edumazet-laptop>
	 <412e6f7f1003230458o459b9e45i7327c5330c43e152@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f179.google.com ([209.85.221.179]:39052 "EHLO
	mail-qy0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753020Ab0CWNGZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Mar 2010 09:06:25 -0400
Received: by qyk9 with SMTP id 9so751408qyk.1
        for <netdev@vger.kernel.org>; Tue, 23 Mar 2010 06:06:24 -0700 (PDT)
In-Reply-To: <412e6f7f1003230458o459b9e45i7327c5330c43e152@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 23 mars 2010 =C3=A0 19:58 +0800, Changli Gao a =C3=A9crit :

> The sysadmins you mentioned above are Linux experters, and they know
> how to tunning the system to get the best performance, but the defaul=
t
> configuration should be for the ordinary users, who don't know Linux
> much.
>=20

I strongly NACK your change at this very moment, many devices run
without a linux expert to tune them, thanks.

Ordinary users dont need RPS magic in 2.6.35.

Maybe in 2.6.38+ we can reconsider this, if RPS deployment happens to b=
e
successful, thanks to experts doing their job and reports.



