From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Quota in __qdisc_run() (was: qdisc: validate skb without
 holding lock)
Date: Tue, 07 Oct 2014 08:06:14 -0700
Message-ID: <1412694374.11091.132.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141003.145647.1980640682969765484.davem@davemloft.net>
	 <1412373477.17245.5.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1412375467.17245.16.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141003.153645.72976986956341944.davem@davemloft.net>
	 <1412379044.17245.26.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141007093441.35ce3a02@redhat.com>
	 <1412686038.11091.111.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141007153050.792c9743@redhat.com>
	 <1412693013.4140057.176149461.0FBF6CBD@webmail.messagingengine.com>
	 <1412694080.11091.131.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	therbert@google.com, fw@strlen.de, dborkman@redhat.com,
	jhs@mojatatu.com, alexander.duyck@gmail.com,
	john.r.fastabend@intel.com, dave.taht@gmail.com, toke@toke.dk
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:49695 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753152AbaJGPGQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 11:06:16 -0400
Received: by mail-pd0-f178.google.com with SMTP id y10so5203401pdj.37
        for <netdev@vger.kernel.org>; Tue, 07 Oct 2014 08:06:16 -0700 (PDT)
In-Reply-To: <1412694080.11091.131.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-10-07 at 08:01 -0700, Eric Dumazet wrote:

> Quota was a packet quota, which was quite irrelevant if segmentation had
> to be done, so I would just let the dequeue be done so that we benefit
> from optimal xmit_more.

And it also is better to allow receiver to get full LRO/GRO aggregation,
if we do not break GSO train in multiple parts.
