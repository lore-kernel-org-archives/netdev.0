From: David Miller <davem@davemloft.net>
Subject: Re: owner-Match in 2.6.20-rc5 (fwd)
Date: Thu, 25 Jan 2007 13:01:11 -0800 (PST)
Message-ID: <20070125.130111.26966608.davem@davemloft.net>
References: <Pine.LNX.4.64.0701252121190.26664@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
To: kadlec@blackhole.kfki.hu
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
In-Reply-To: <Pine.LNX.4.64.0701252121190.26664@blackhole.kfki.hu>
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

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Date: Thu, 25 Jan 2007 21:31:56 +0100 (CET)

> The report below was posted on the netfilter user list. Isn't there any 
> ill side effect by reverting the change?

Performance regression :-(

This optimization saves a whole handful of heavy atomic operations in
the packet transmit path of TCP.

As I understand it, the owner-Match is not in the upstream tree, and
it's the only thing that cares, so I see no reason to cater for it.
