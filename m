From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] reduce netfilte sk_buff enlargement
Date: Thu, 21 Jul 2005 16:52:07 -0700 (PDT)
Message-ID: <20050721.165207.35016196.davem@davemloft.net>
References: <1121982131.5886.2.camel@notepaq>
	<20050721.152941.56567834.davem@davemloft.net>
	<1121989791.5892.8.camel@notepaq>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: laforge@netfilter.org, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org, wensong@linux-vs.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: marcel@holtmann.org
In-Reply-To: <1121989791.5892.8.camel@notepaq>
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

From: Marcel Holtmann <marcel@holtmann.org>
Date: Fri, 22 Jul 2005 01:49:51 +0200

> The pkt_type zero is not a valid one. We only use 1-4 and 0xff. So this
> can't be the problem. I assume that the cb is not copied from the driver
> into the core at some point.

All clones and copies of SKBs copy of the ->cb[] for you.
So perhaps something is spamming the ->cb[] between these
two places.
