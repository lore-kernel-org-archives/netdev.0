From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH 1/1 V4] qdisc: bulk dequeue support for qdiscs
 with TCQ_F_ONETXQUEUE
Date: Wed, 24 Sep 2014 18:13:57 -0400
Message-ID: <54234225.5000503@mojatatu.com>
References: <20140924160932.9721.56450.stgit@localhost>	<20140924161047.9721.43080.stgit@localhost>	<1411579395.15395.41.camel@edumazet-glaptop2.roam.corp.google.com> <20140924195831.6fb91051@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com,
	"David S. Miller" <davem@davemloft.net>,
	Alexander Duyck <alexander.h.duyck@intel.com>, toke@toke.dk,
	Florian Westphal <fw@strlen.de>,
	Dave Taht <dave.taht@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:36490 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751184AbaIXWOG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 18:14:06 -0400
Received: by mail-ie0-f170.google.com with SMTP id x19so9702718ier.15
        for <netdev@vger.kernel.org>; Wed, 24 Sep 2014 15:14:05 -0700 (PDT)
In-Reply-To: <20140924195831.6fb91051@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/24/14 13:58, Jesper Dangaard Brouer wrote:
> On Wed, 24 Sep 2014 10:23:15 -0700
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>

>
>> pktgen is nice, but do not represent the majority of the traffic we send
>> from high performance host where we want this bulk dequeue thing ;)
>
> This patch is actually targetted towards more normal use-cases.
> Pktgen cannot even use this work, as it bypass the qdisc layer...

When you post these patches - can you please also post basic performance
numbers? You dont have to show improvement if it is hard for bulking
to kick in, but you need to show no harm in at least latency for the
general use case (i.e not pktgen maybe forwarding activity or something
sourced from tcp).

cheers,
jamal
