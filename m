From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC 5/7] bnx2: use netdev_irqname
Date: Tue, 21 Jun 2011 19:11:51 +0100
Message-ID: <1308679911.2743.45.camel@bwh-desktop>
References: <20110621170541.309890798@vyatta.com>
	 <20110621170658.788401517@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:8150 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751554Ab1FUSLy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 14:11:54 -0400
In-Reply-To: <20110621170658.788401517@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-06-21 at 10:05 -0700, Stephen Hemminger wrote:

> Also increase size of irq name to account for longer device names.
> Original code was broken for full size names.
[...]

We should define a macro for the maximum netdev IRQ name length.  I
think this would be IFNAMSIZ + 1 + 2 + 1 + 5 (2 characters for queue
type; up to 5 digits for 16-bit queue index).

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

