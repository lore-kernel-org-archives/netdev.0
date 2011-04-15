From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/3] net: Add net device irq siloing feature
Date: Fri, 15 Apr 2011 23:49:03 +0100
Message-ID: <1302907743.2845.23.camel@bwh-desktop>
References: <1302898677-3833-1-git-send-email-nhorman@tuxdriver.com>
	 <1302898677-3833-3-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Dimitris Michailidis <dm@chelsio.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	David Howells <dhowells@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:3478 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751400Ab1DOXBH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 19:01:07 -0400
In-Reply-To: <1302898677-3833-3-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-04-15 at 16:17 -0400, Neil Horman wrote:
> Using the irq affinity infrastrucuture, we can now allow net devices to call
> request_irq using a new wrapper function (request_net_irq), which will attach a
> common affinty_update handler to each requested irq.  This affinty update
> mechanism correlates each tracked irq to the flow(s) that said irq processes
> most frequently.  The highest traffic flow is noted, marked and exported to user
> space via the affinity_hint proc file for each irq. In this way, utilities like
> irqbalance are able to determine  which cpu is recieving the most data from each
> rx queue on a given NIC, and set irq affinity accordingly.
[...]

Is irqbalance expected to poll the affinity hints?  How often?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

