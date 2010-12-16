From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v2 net-next-2.6] netfilter: ip_tables: dont block BH
 while reading counters
Date: Thu, 16 Dec 2010 09:31:49 -0800
Message-ID: <20101216093149.71f082c7@nehalam>
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
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1292518436.2883.393.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 16 Dec 2010 17:53:56 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

>  	spinlock_t lock;
> +	seqcount_t seq;

Since lock and seqcount_t are associated together, why isn't this a seqlock instead?

-- 
