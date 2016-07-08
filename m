From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next] ipv6: do not abuse GFP_ATOMIC in
 inet6_netconf_notify_devconf()
Date: Fri, 8 Jul 2016 09:58:28 +0200
Message-ID: <577F5D24.3060307@6wind.com>
References: <1467764916-4983-1-git-send-email-masashi.honma@gmail.com>
 <1467764916-4983-6-git-send-email-masashi.honma@gmail.com>
 <1467946591.1273.45.camel@edumazet-glaptop3.roam.corp.google.com>
 <1467947904.1273.56.camel@edumazet-glaptop3.roam.corp.google.com>
 <1467949564.1273.61.camel@edumazet-glaptop3.roam.corp.google.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Masashi Honma <masashi.honma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:36659 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752700AbcGHH6c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 03:58:32 -0400
Received: by mail-wm0-f53.google.com with SMTP id f126so7684898wma.1
        for <netdev@vger.kernel.org>; Fri, 08 Jul 2016 00:58:31 -0700 (PDT)
In-Reply-To: <1467949564.1273.61.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 08/07/2016 05:46, Eric Dumazet a =C3=A9crit :
> From: Eric Dumazet <edumazet@google.com>
>=20
> All inet6_netconf_notify_devconf() callers are in process context,
> so we can use GFP_KERNEL allocations if we take care of not holding
> a rwlock while not needed in ip6mr (we hold RTNL there)
>=20
>=20
> Fixes: d67b8c616b48 ("netconf: advertise mc_forwarding status")
> Fixes: f3a1bfb11ccb ("rtnl/ipv6: use netconf msg to advertise forward=
ing status")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Also nice, thanks.
