From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] ipv4: add rcu annotations in route.c
Date: Fri, 17 Sep 2010 21:59:33 +0200
Message-ID: <1284753573.4373.7.camel@edumazet-laptop>
References: <1284739159.3391.95.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:46332 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753023Ab0IQT7k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Sep 2010 15:59:40 -0400
Received: by wwb39 with SMTP id 39so1311429wwb.1
        for <netdev@vger.kernel.org>; Fri, 17 Sep 2010 12:59:38 -0700 (PDT)
In-Reply-To: <1284739159.3391.95.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 17 septembre 2010 =C3=A0 17:59 +0200, Eric Dumazet a =C3=A9=
crit :
> Use __rcu attribute where appropriate.
>=20
> Use rcu_dereference_raw() in contexts where no lock is held.
>=20
> Use rcu_dereference_check() in contexts where the chain spinlock is
> held.

Hmm, it should be rcu_dereference_protected(), I'll send a v2

This is a bit tricky ...



