From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: unix: make some variables constant
Date: Tue, 19 Oct 2010 07:47:43 +0200
Message-ID: <1287467263.2775.2.camel@edumazet-laptop>
References: <1287465842-2958-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:58328 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751684Ab0JSFrt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Oct 2010 01:47:49 -0400
Received: by wyb28 with SMTP id 28so2108269wyb.19
        for <netdev@vger.kernel.org>; Mon, 18 Oct 2010 22:47:48 -0700 (PDT)
In-Reply-To: <1287465842-2958-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 19 octobre 2010 =C3=A0 13:24 +0800, Changli Gao a =C3=A9crit :
> And since ctl_table.data is initialized later, we don't need to initi=
alize
> the data member of the template variable unix_table.
>=20

The init cost is nothing, since its a data blob that must be there
anyway.

We could even avoid the kmemdup() if CONFIG_NET_NS is not set




