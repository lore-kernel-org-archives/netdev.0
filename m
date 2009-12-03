From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH v2] net: Introduce realloc_netdev_mq()
Date: Thu, 3 Dec 2009 17:54:49 +0100
Message-ID: <20091203165449.GA2960@ami.dom.local>
References: <20091101132017.GA2598@ami.dom.local>
 <20091102.033533.08766686.davem@davemloft.net>
 <20091102123029.GA7790@ff.dom.local>
 <20091102.043907.236634594.davem@davemloft.net>
 <20091203143918.GA20526@ff.dom.local>
 <4B17D697.8000105@gmail.com>
 <20091203163640.GA2584@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, mchan@broadcom.com,
	kaber@trash.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:32873 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753610AbZLCQzJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 11:55:09 -0500
Received: by bwz27 with SMTP id 27so1280952bwz.21
        for <netdev@vger.kernel.org>; Thu, 03 Dec 2009 08:55:15 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20091203163640.GA2584@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 03, 2009 at 05:36:40PM +0100, Jarek Poplawski wrote:
> On Thu, Dec 03, 2009 at 04:17:43PM +0100, Eric Dumazet wrote:
> > if (realloc_netdev_mq(dev, real_queues))
> > 	dev->real_num_tx_queues = real_queues;
> > 
> > In this case the memory error is not fatal.
> 
> Good point! We can consider doing this inside the function too?

Hmm... Of course, not exactly this - I mean using min().

Jarek P.
