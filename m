From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [PATCH 1/2]: softirq: Add support for triggering softirq work
 on softirqs.
Date: Fri, 19 Sep 2008 09:57:30 -0700 (PDT)
Message-ID: <31089112.38051221843450562.JavaMail.root@tahiti.vyatta.com>
References: <20080918.023614.193687634.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: jens axboe <jens.axboe@oracle.com>, netdev@vger.kernel.org,
	nickpiggin@yahoo.com.au, ilpo jarvinen <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54052 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750945AbYISREx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Sep 2008 13:04:53 -0400
In-Reply-To: <20080918.023614.193687634.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I wonder if the added overhead of local_irq_disable/local_irq_enable is
killing any performance gain. Certainly it adds more latency to a sensitive code path.

Is there a good lock-less solution?
