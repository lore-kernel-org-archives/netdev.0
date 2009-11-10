From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ifb: add multi-queue support
Date: Tue, 10 Nov 2009 11:57:32 +0100
Message-ID: <4AF9471C.5080606@gmail.com>
References: <4AF924A5.1050303@gmail.com> <4AF92D6D.8060300@gmail.com> <412e6f7f0911100143k68284faes92e39d8ca94aa9d4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Tom Herbert <therbert@google.com>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:35225 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751214AbZKJK5e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 05:57:34 -0500
In-Reply-To: <412e6f7f0911100143k68284faes92e39d8ca94aa9d4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changli Gao a =A8=A6crit :
> 2009/11/10 Eric Dumazet <eric.dumazet@gmail.com>:
>> Not sure how to solve this problem (several cpus can updates counter=
 in //)
>>
> Thanks, and follow your suggestions. I can maintain the counter per T=
X
> queue, and update it in a timer handler like ixgbe or implement our
> own struct net_device_stats* (*ndo_get_stats)(struct net_device *dev)=
,
> and update the counters when it gets called.

Please no timer stuff :)

