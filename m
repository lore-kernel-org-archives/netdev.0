From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bgmac: omit the fcs
Date: Thu, 28 Feb 2013 14:16:08 -0800
Message-ID: <1362089768.15793.49.camel@edumazet-glaptop>
References: <1362071814-12822-1-git-send-email-hauke@hauke-m.de>
	 <CACna6rw6MR3agrDvz0+X7ne6uSNQN0tpZupeM5c-6xy5-pvv2Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hauke Mehrtens <hauke@hauke-m.de>, davem@davemloft.net,
	netdev@vger.kernel.org
To: =?UTF-8?Q?Rafa=C5=82_Mi=C5=82ecki?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:54415 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755493Ab3B1WQL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2013 17:16:11 -0500
Received: by mail-pb0-f42.google.com with SMTP id xb4so1326888pbc.15
        for <netdev@vger.kernel.org>; Thu, 28 Feb 2013 14:16:10 -0800 (PST)
In-Reply-To: <CACna6rw6MR3agrDvz0+X7ne6uSNQN0tpZupeM5c-6xy5-pvv2Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-02-28 at 18:57 +0100, Rafa=C5=82 Mi=C5=82ecki wrote:

> Is this a real fix?
>=20
> Don't get me wrong, but it sounds a little like a workaround for some
> issue in another network layer ;)

It looks a real fix in a forwarding workload, or else MTU would need 4
extra bytes.
