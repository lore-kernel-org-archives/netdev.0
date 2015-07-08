From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ifb: add multiqueue operation
Date: Wed, 08 Jul 2015 15:06:18 +0200
Message-ID: <1436360778.24939.7.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1436213128.4571.14.camel@edumazet-glaptop2.roam.corp.google.com>
	 <559D17BA.50105@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Alexei Starovoitov <ast@plumgrid.com>,
	John Fastabend <john.fastabend@gmail.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:37149 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758519AbbGHNGZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 09:06:25 -0400
Received: by wiclp1 with SMTP id lp1so79893739wic.0
        for <netdev@vger.kernel.org>; Wed, 08 Jul 2015 06:06:23 -0700 (PDT)
In-Reply-To: <559D17BA.50105@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-07-08 at 08:29 -0400, Jamal Hadi Salim wrote:
> On 07/06/15 16:05, Eric Dumazet wrote:
> > From: Eric Dumazet <edumazet@google.com>
> >
> > Add multiqueue capabilities to ifb netdevice.
> >
> > This removes last bottleneck for ingress when mq qdisc can be used
> > to shard load from multiple RX queues on physical device.
> >
> 
> Looks good to me ;->
> Any perf numbers before/after the change?

It all depends on he workload.

If indeed mq can be used as qdisc on ifb as I did, we remove the ~1 Mpps
limit and can get whatever incoming NIC can provide, like 10 Mpps,
assuming 8 or 16 queues.
