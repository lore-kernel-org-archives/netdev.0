From: David Miller <davem@davemloft.net>
Subject: Re: WARNING: at net/ipv4/af_inet.c:154 inet_sock_destruct
Date: Fri, 06 Nov 2009 00:58:42 -0800 (PST)
Message-ID: <20091106.005842.231236256.davem@davemloft.net>
References: <4AEB0059.1050400@gmail.com>
	<38b2ab8a0911060045hb6ebab8p43bf8aa838eabfd3@mail.gmail.com>
	<4AF3E2A9.2020601@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: francis.moro@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47208
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755186AbZKFI6R convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Nov 2009 03:58:17 -0500
In-Reply-To: <4AF3E2A9.2020601@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 06 Nov 2009 09:47:37 +0100

> Francis Moreau a =E9crit :
>> On Fri, Oct 30, 2009 at 4:03 PM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:
>>=20
>> [...]
>>=20
>>> [PATCH take2] net: fix sk_forward_alloc corruption
>>>
>>=20
>> With this patch applied 4 days ago, I haven't got any oops so far.
>
> Thanks a lot for testing and report Francis, I believe David will
> push it for stable (if not already done)

I'm pretty sure it's already in Greg's current batch, but if it
doesn't show up in his next -stable release I'll make sure to
submit it.
