From: Florian Weimer <fw@deneb.enyo.de>
Subject: Re: purpose of the skb head pool
Date: Thu, 01 May 2003 12:38:38 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <877k9bc5ox.fsf@deneb.enyo.de>
References: <20030429135506.A22411@lst.de>
	<16046.30879.738356.495523@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@lst.de>, davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16046.30879.738356.495523@robur.slu.se> (Robert Olsson's
 message of "Tue, 29 Apr 2003 15:05:35 +0200")
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Robert Olsson <Robert.Olsson@data.slu.se> writes:

>  2.6.66 IP. Forwarding of two input simplex flows. eth0->eth1, eth2->eth3 
>  Fixed affinity CPU0: eth0, eth3. CPU1: eth1, eth2. Which common for routing
>  and should be "worst case" for other use. The test should give a very high 
>  load on the packet memory system. As seen at least we don't see any
>  improvement from skb_head_pool code. 
>
>
>  Vanilla 2.5.66              381 kpps
>  Magazine                    431 kpps
>  Magazine + no skb_head_pool 435 kpps

Can you rerun this test with random source/destination addresses, to
get more realistic (for some configurations) numbers?
