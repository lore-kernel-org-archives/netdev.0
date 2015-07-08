From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next] ifb: add multiqueue operation
Date: Wed, 08 Jul 2015 08:29:46 -0400
Message-ID: <559D17BA.50105@mojatatu.com>
References: <1436213128.4571.14.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Alexei Starovoitov <ast@plumgrid.com>,
	John Fastabend <john.fastabend@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:35124 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758518AbbGHM3z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 08:29:55 -0400
Received: by igcqs7 with SMTP id qs7so54765099igc.0
        for <netdev@vger.kernel.org>; Wed, 08 Jul 2015 05:29:54 -0700 (PDT)
In-Reply-To: <1436213128.4571.14.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/06/15 16:05, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Add multiqueue capabilities to ifb netdevice.
>
> This removes last bottleneck for ingress when mq qdisc can be used
> to shard load from multiple RX queues on physical device.
>

Looks good to me ;->
Any perf numbers before/after the change?

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
