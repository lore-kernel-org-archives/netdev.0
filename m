From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 00/10]: Netfilter IPsec support
Date: Thu, 10 Nov 2005 21:17:24 -0800 (PST)
Message-ID: <20051110.211724.83727693.davem@davemloft.net>
References: <43740D9C.80003@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: kaber@trash.net
In-Reply-To: <43740D9C.80003@trash.net>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Fri, 11 Nov 2005 04:18:52 +0100

> This is the latest set patches for netfilter IPsec support.
> The use of netif_rx for the innermost SA if it used transport
> mode has been replaced by explicit NF_HOOK calls in
> xfrm{4,6}_input.c.

Note that I consider this stuff 2.6.16 material.

We do have a lot of networking changes in 2.6.15
as it is, and also it would be good for these changes
to get some review and discussion time.
