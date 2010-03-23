From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] rps: make distributing packets fairly among all the
 online CPUs default
Date: Tue, 23 Mar 2010 12:23:42 +0100
Message-ID: <1269343422.2983.1.camel@edumazet-laptop>
References: <4BA85EA2.1090304@gmail.com>
	 <1269328852.3043.13.camel@edumazet-laptop>
	 <412e6f7f1003230256m109644b0n2988e86a56f1ae1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f172.google.com ([209.85.211.172]:57859 "EHLO
	mail-yw0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751253Ab0CWLXu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Mar 2010 07:23:50 -0400
Received: by ywh2 with SMTP id 2so2289960ywh.33
        for <netdev@vger.kernel.org>; Tue, 23 Mar 2010 04:23:50 -0700 (PDT)
In-Reply-To: <412e6f7f1003230256m109644b0n2988e86a56f1ae1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 23 mars 2010 =C3=A0 17:56 +0800, Changli Gao a =C3=A9crit :
> On Tue, Mar 23, 2010 at 3:20 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
> > Le mardi 23 mars 2010 =C3=A0 14:24 +0800, Changli Gao a =C3=A9crit =
:
> >
> > You cannot do this like this, these allocations wont be freed.
> >
> > Better would be to take a look at net/core/net-sysfs.c
> >
>=20
> Sorry, but I don't know why these allocations won't be freed.
>=20
>=20

Hint : This will be freed only if CONFIG_SYSFS is set



