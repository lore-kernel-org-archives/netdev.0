From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next 1/4] net: implement support
 for low latency socket polling
Date: Tue, 21 May 2013 10:51:26 -0700
Message-ID: <1369158686.3301.237.camel@edumazet-glaptop>
References: <20130520101552.14133.45953.stgit@ladj378.jer.intel.com>
	<20130520101601.14133.874.stgit@ladj378.jer.intel.com>
	<1369063764.3301.182.camel@edumazet-glaptop>
	<519B2237.20204@linux.intel.com>
	<1369142926.3301.213.camel@edumazet-glaptop>
	<alpine.GSO.2.00.1305211855120.9230@git.silcnet.org>
	<1369158499.3301.236.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, Don,
	Eliezer Tamir <eliezer.tamir@linux.intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	HPA <hpa@zytor.com>, Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org, Andi Kleen <andi@firstfloor.org>,
	Eliezer Tamir <eliezer@tamir.org.il>, Dave Miller <davem@davemloft.net>
To: Pekka Riikonen <priikone@iki.fi>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1369158499.3301.236.camel@edumazet-glaptop>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tue, 2013-05-21 at 10:48 -0700, Eric Dumazet wrote:

> We do not keep skb->dev information once a packet leaves the rcu
> protected region.
> 
> Once packet is queued to tcp input queues, skb->dev is NULL.

This is done in tcp_v4_rcv() & tcp_v6_rcv()




------------------------------------------------------------------------------
Try New Relic Now & We'll Send You this Cool Shirt
New Relic is the only SaaS-based application performance monitoring service 
that delivers powerful full stack analytics. Optimize and monitor your
browser, app, & servers with just a few lines of code. Try New Relic
and get this awesome Nerd Life shirt! http://p.sf.net/sfu/newrelic_d2d_may
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
