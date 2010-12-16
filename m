From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v3 net-next-2.6] netfilter: x_tables: dont block BH
 while reading counters
Date: Thu, 16 Dec 2010 09:57:40 -0800
Message-ID: <20101216095740.301b6acc@nehalam>
References: <1292337974.9155.68.camel@firesoul.comx.local>
	<1292340702.5934.5.camel@edumazet-laptop>
	<1292342958.9155.91.camel@firesoul.comx.local>
	<1292343855.5934.27.camel@edumazet-laptop>
	<1292508266.31289.12.camel@firesoul.comx.local>
	<1292508733.2883.152.camel@edumazet-laptop>
	<1292509489.31289.20.camel@firesoul.comx.local>
	<1292509775.2883.187.camel@edumazet-laptop>
	<1292511761.2883.236.camel@edumazet-laptop>
	<1292515625.2883.336.camel@edumazet-laptop>
	<1292518436.2883.393.camel@edumazet-laptop>
	<20101216093149.71f082c7@nehalam>
	<1292521986.2883.472.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@comx.dk>,
	Patrick McHardy <kaber@trash.net>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Steven Rostedt <srostedt@redhat.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34047 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755684Ab0LPR5n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Dec 2010 12:57:43 -0500
In-Reply-To: <1292521986.2883.472.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 16 Dec 2010 18:53:06 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> [PATCH v3 net-next-2.6] netfilter: x_tables: dont block BH while reading counters
> 
> Using "iptables -L" with a lot of rules might have a too big BH latency.
> Jesper mentioned ~6 ms and worried of frame drops.
> 
> Switch to a per_cpu seqcount scheme, so that taking a snapshot of
> counters doesnt need to block BH (for this cpu, but also other cpus).
> 
> Reported-by: Jesper Dangaard Brouer <hawk@comx.dk>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Acked-by: Stephen Hemminger <shemminger@vyatta.com>

-- 
