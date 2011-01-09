From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v4 net-next-2.6] netfilter: x_tables: dont block BH while
 reading counters
Date: Sun, 09 Jan 2011 22:31:06 +0100
Message-ID: <4D2A291A.4040204@netfilter.org>
References: <1292337974.9155.68.camel@firesoul.comx.local>	 <1292340702.5934.5.camel@edumazet-laptop>	 <1292342958.9155.91.camel@firesoul.comx.local>	 <1292343855.5934.27.camel@edumazet-laptop>	 <1292508266.31289.12.camel@firesoul.comx.local>	 <1292508733.2883.152.camel@edumazet-laptop>	 <1292509489.31289.20.camel@firesoul.comx.local>	 <1292509775.2883.187.camel@edumazet-laptop>	 <1292511761.2883.236.camel@edumazet-laptop>	 <1292515625.2883.336.camel@edumazet-laptop>	 <1292518436.2883.393.camel@edumazet-laptop>	 <20101216093149.71f082c7@nehalam>	 <1292521986.2883.472.camel@edumazet-laptop>	 <1292646579.7894.42.camel@edumazet-laptop> <1294505112.2709.534.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	Jesper Dangaard Brouer <hawk@comx.dk>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1294505112.2709.534.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/01/11 17:45, Eric Dumazet wrote:
> David,
> 
> I am resending this patch, sent 3 weeks ago, Patrick gave no answer.
> 
> I believe it should be included in linux-2.6.38 and stable kernels.
> 
> Some people found they had to change NIC RX ring sizes in order not
> missing frames (from 1024 to 2048), while root cause of the problem was
> this.
> 
> Quoting Jesper : "I can now hit the system with a pktgen at 128 bytes,
> and see no drops/overruns while running iptables.  (This packet load at
> 128bytes is 822 kpps and 840Mbit/s) (iptables ruleset is the big chains:
> 20929 rules: 81239)."

I have enqueued this patch to me tree.

http://1984.lsi.us.es/git/?p=net-2.6/.git;a=summary

I'll pass it to davem for -stable submission.
