From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: batch skb dequeueing from softnet
 input_pkt_queue
Date: Thu, 22 Apr 2010 00:17:18 -0700 (PDT)
Message-ID: <20100422.001718.112184991.davem@davemloft.net>
References: <1271891149.7895.3751.camel@edumazet-laptop>
	<j2s412e6f7f1004212333se60a9083s59185ee3466313f@mail.gmail.com>
	<1271920402.7895.4732.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, netdev@vger.kernel.org, therbert@google.com,
	hadi@cyberus.ca
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45857
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751789Ab0DVHRN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 03:17:13 -0400
In-Reply-To: <1271920402.7895.4732.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 22 Apr 2010 09:13:22 +0200

> No thanks, this is out of the question.
> 
> Talk to ixiacom guys, some people settle/dismantle dozens of network
> device per second, on production machines.

Yes, ifup/ifdown performance is very important these days.

Recently we've had to do a lot of work to increase scalability and
latency in this area, let's not undo that.
