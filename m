From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] ifb: add multi-queue support
Date: Tue, 10 Nov 2009 17:43:58 +0800
Message-ID: <412e6f7f0911100143k68284faes92e39d8ca94aa9d4@mail.gmail.com>
References: <4AF924A5.1050303@gmail.com> <4AF92D6D.8060300@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Tom Herbert <therbert@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f188.google.com ([209.85.222.188]:40403 "EHLO
	mail-pz0-f188.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755841AbZKJJnw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 04:43:52 -0500
Received: by pzk26 with SMTP id 26so2729162pzk.4
        for <netdev@vger.kernel.org>; Tue, 10 Nov 2009 01:43:58 -0800 (PST)
In-Reply-To: <4AF92D6D.8060300@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2009/11/10 Eric Dumazet <eric.dumazet@gmail.com>:
>
> Not sure how to solve this problem (several cpus can updates counter =
in //)
>
Thanks, and follow your suggestions. I can maintain the counter per TX
queue, and update it in a timer handler like ixgbe or implement our
own struct net_device_stats* (*ndo_get_stats)(struct net_device *dev),
and update the counters when it gets called.



--=20
Regards=A3=AC
Changli Gao(xiaosuo@gmail.com)
