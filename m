From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] xps-mq: Transmit Packet Steering for multiqueue
Date: Mon, 23 Aug 2010 18:09:09 +0100
Message-ID: <1282583349.2267.30.camel@achroite.uk.solarflarecom.com>
References: <alpine.DEB.1.00.1008222233530.31382@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:25187 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753851Ab0HWRJN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 13:09:13 -0400
In-Reply-To: <alpine.DEB.1.00.1008222233530.31382@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2010-08-22 at 22:39 -0700, Tom Herbert wrote:
[...]
> Each transmit queue can be associated with a number of CPUs which will
> used the queue to send packets.  This is configured as a CPU mask on a
> per queue basis in:
> 
> /sys/class/net/eth<n>/queues/tx-<n>/xps_cpus
> 
> The mappings are stored per device in an inverted data structure that
> maps CPUs to queues.  In the netdevice structure this is an array of
> num_possible_cpu structures where each array entry contains a bit map
> of queues which that CPU can use.
[...]

The mapping of TX queue to CPU should match the affinity of the
completion IRQ for that queue.  It should not be a separate setting.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

