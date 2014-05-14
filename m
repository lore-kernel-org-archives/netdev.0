From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH 2/5] ixgbe: increase default TX ring buffer to
 1024
Date: Wed, 14 May 2014 21:25:12 +0200
Message-ID: <20140514212512.196b5136@redhat.com>
References: <20140514141545.20309.28343.stgit@dragon>
	<20140514141748.20309.83121.stgit@dragon>
	<063D6719AE5E284EB5DD2968C1650D6D1724483B@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	"Florian Westphal" <fw@strlen.de>,
	"David S. Miller" <davem@davemloft.net>,
	"Stephen Hemminger" <shemminger@vyatta.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Robert Olsson <robert@herjulf.se>,
	Ben Greear <greearb@candelatech.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	"danieltt@kth.se" <danieltt@kth.se>,
	"zhouzhouyi@gmail.com" <zhouzhouyi@gmail.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9469 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750750AbaENTZg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2014 15:25:36 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1724483B@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 May 2014 14:28:24 +0000
David Laight <David.Laight@ACULAB.COM> wrote:

> From: Jesper Dangaard Brouer
> > Using pktgen I'm seeing the ixgbe driver "push-back", due TX ring
> > running full.  Thus, the TX ring is artificially limiting pktgen.
> > 
> > Diagnose via "ethtool -S", look for "tx_restart_queue" or "tx_busy"
> > counters.
> 
> Have you tried reducing the tx interrupt mitigation delay.
> It might just be that the end of tx interrupt is delayed too long.

Does the ixgbe have TX interrupt mitigation delays?

I don't "see" them:

$ sudo ethtool -c eth8 
Coalesce parameters for eth8:
Adaptive RX: off  TX: off
stats-block-usecs: 0
sample-interval: 0
pkt-rate-low: 0
pkt-rate-high: 0

rx-usecs: 1
rx-frames: 0
rx-usecs-irq: 0
rx-frames-irq: 0

tx-usecs: 0
tx-frames: 0
tx-usecs-irq: 0
tx-frames-irq: 0

rx-usecs-low: 0
rx-frame-low: 0
tx-usecs-low: 0
tx-frame-low: 0

rx-usecs-high: 0
rx-frame-high: 0
tx-usecs-high: 0
tx-frame-high: 0


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
