From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 11/36] ixgbe,
 rcu: convert call_rcu(ring_free_rcu) to kfree_rcu()
Date: Fri, 18 Mar 2011 12:36:11 -0700 (PDT)
Message-ID: <20110318.123611.115937040.davem@davemloft.net>
References: <4D82D821.1070101@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, bruce.w.allan@intel.com,
	jesse.brandeburg@intel.com, linux-kernel@vger.kernel.org,
	john.ronciak@intel.com, netdev@vger.kernel.org, mingo@elte.hu,
	paulmck@linux.vnet.ibm.com
To: laijs@cn.fujitsu.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <4D82D821.1070101@cn.fujitsu.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Lai Jiangshan <laijs@cn.fujitsu.com>
Date: Fri, 18 Mar 2011 11:57:21 +0800

> 
> 
> The rcu callback ring_free_rcu() just calls a kfree(),
> so we use kfree_rcu() instead of the call_rcu(ring_free_rcu).
> 
> Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>

Acked-by: David S. Miller <davem@davemloft.net>

------------------------------------------------------------------------------
Colocation vs. Managed Hosting
A question and answer guide to determining the best fit
for your organization - today and in the future.
http://p.sf.net/sfu/internap-sfd2d
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
