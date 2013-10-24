From: David Miller <davem@davemloft.net>
Subject: Re: 16% regression on 10G caused by TCP small queues
Date: Thu, 24 Oct 2013 03:01:21 -0400 (EDT)
Message-ID: <20131024.030121.477884925478012615.davem@davemloft.net>
References: <CAOaVG15indAxBz7E-T+9MK03indiXBa0UhQZ5j6K5DxYP44Mxg@mail.gmail.com>
	<20131023.233816.1396918839771657154.davem@davemloft.net>
	<20131023214557.386aad1a@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, eric.dumazet@gmail.com,
	dave.taht@bufferbloat.net, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43616 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753872Ab3JXHBf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 03:01:35 -0400
In-Reply-To: <20131023214557.386aad1a@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Wed, 23 Oct 2013 21:45:57 -0700

> Sorry, thought sk_pacing_rate depended on FQ qdisc but it is other way around.
> In which case doing merge of these two was sufficient to fix the problem.
> With a minor manual fix up to tcp.h.

I know, I already have a half-built tree of -stable submissions
that does exactlty this.
