From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6] iptables CLUSTERIP target, seq_file version
Date: Thu, 21 Oct 2004 22:52:08 -0700
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <20041021225208.44ddaa10.davem@davemloft.net>
References: <20041020223828.GP19899@sunbeam.de.gnumonks.org>
	<20041021163655.GK3551@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org, lmb@suse.de
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20041021163655.GK3551@sunbeam.de.gnumonks.org>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

On Thu, 21 Oct 2004 18:36:55 +0200
Harald Welte <laforge@netfilter.org> wrote:

> This is the 'CLUSTERIP' target for iptables, this time no core kernel
> changes required, please apply.
> 
> This enables you to build a static load sharing cluster between multiple
> nodes - without the requirement to have a load balancer.  It uses a
> series of [evil] tricks like replying with linklayer multicast addresses
> to ARP requests, and using CONNMARK for stateful blocking all traffic
> not intended for the local node.

It's clever and nasty, I like it :-)

Thanks for cleaning it up to use seq_file.  Patch applied.
