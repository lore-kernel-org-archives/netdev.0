From: Sonic Zhang <sonic.adi@gmail.com>
Subject: Re: [PATCH v2] netdev:bfin_mac: reclaim and free tx skb as soon as
	possible after transfer
Date: Mon, 7 Jun 2010 18:26:32 +0800
Message-ID: <AANLkTimTakJHg2wTrPjhgLPK7vh2qDjKgZVKuJ1si8er@mail.gmail.com>
References: <1275536881.18536.5.camel@eight.analog.com>
	<AANLkTik4aWREeblhnbI3DU7a_CE11Rx0GvXi56O2yHzy@mail.gmail.com>
	<1275624354.2533.121.camel@edumazet-laptop>
	<AANLkTimO47rtvIwYAwpaMYtK5SEnhM0m3AxL5q-8lvA7@mail.gmail.com>
	<1275904680.2545.44.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	uclinux-dist-devel <uclinux-dist-devel@blackfin.uclinux.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:40467 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751348Ab0FGK0f convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 06:26:35 -0400
Received: by vws5 with SMTP id 5so3280527vws.19
        for <netdev@vger.kernel.org>; Mon, 07 Jun 2010 03:26:34 -0700 (PDT)
In-Reply-To: <1275904680.2545.44.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 7, 2010 at 5:58 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le vendredi 04 juin 2010 =E0 12:44 +0800, Sonic Zhang a =E9crit :
>
>>
>> Yes, you are right. dev_kfree_skb_irq() queues used skb to the
>> complete queue. But, it is actually freed in the other soft irq
>> NET_TX_SOFTIRQ.
>
> I guess you didnt understood my mail, so I'll re-explain :
>
> dev_kfree_skb_irq() queues skb only if packet is not already orphaned=
=2E
>
> As most packets are now orphaned (in recent kernels where your patch
> applies), dev_kfree_skb_irq() can free packet immediately, with no
> NET_TX_SOFTIRQ overhead.
>
>

OK. I didn't notice the recent change in kernel to orphan most
packets. You are right, my second reason is out of date.

Thanks

Sonic

>
>
