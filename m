From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v3] net: batch skb dequeueing from softnet input_pkt_queue
Date: Thu, 22 Apr 2010 14:33:29 +0800
Message-ID: <j2s412e6f7f1004212333se60a9083s59185ee3466313f@mail.gmail.com>
References: <1271238738-8386-1-git-send-email-xiaosuo@gmail.com>
	<1271891149.7895.3751.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Tom Herbert <therbert@google.com>, jamal <hadi@cyberus.ca>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:42650 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751408Ab0DVGdu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 02:33:50 -0400
Received: by bwz25 with SMTP id 25so9127499bwz.28
        for <netdev@vger.kernel.org>; Wed, 21 Apr 2010 23:33:49 -0700 (PDT)
In-Reply-To: <1271891149.7895.3751.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 22, 2010 at 7:05 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le mercredi 14 avril 2010 =C3=A0 17:52 +0800, Changli Gao a =C3=A9cri=
t :
>> batch skb dequeueing from softnet input_pkt_queue
>>
>> batch skb dequeueing from softnet input_pkt_queue to reduce potentia=
l lock
>> contention and irq disabling/enabling.
>>
>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>> ----
>
> lock contention _is_ a problem, Jamal tests can show it.
>
> irq disabling/enabling is not, and force to use stop_machine() killer=
=2E
>

Although irq_disabling/enabling is not, we should do our best to make
fast path as quickly as possible, and because stop_machine() is used
in slow patch, I think we can afford its weight.


--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
