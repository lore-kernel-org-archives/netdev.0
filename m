From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/2 v7] xps: Transmit Packet Steering
Date: Thu, 25 Nov 2010 17:12:43 +0000
Message-ID: <1290705163.4274.12.camel@localhost>
References: <alpine.DEB.2.00.1011211501430.14906@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:26763 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753817Ab0KYRMu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Nov 2010 12:12:50 -0500
In-Reply-To: <alpine.DEB.2.00.1011211501430.14906@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2010-11-21 at 15:17 -0800, Tom Herbert wrote:
[...]
> Each transmit queue can be associated with a number of CPUs which will
> use the queue to send packets.  This is configured as a CPU mask on a
> per queue basis in:
> 
> /sys/class/net/eth<n>/queues/tx-<n>/xps_cpus
> 
> The mappings are stored per device in an inverted data structure that
> maps CPUs to queues.  In the netdevice structure this is an array of
> num_possible_cpu structures where each structure holds and array of
> queue_indexes for queues which that CPU can use.
[...]

I was thinking we could also use CPU reverse-mapping from IRQ affinity
to set this up automatically - maybe leaving an option for manual
override?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

