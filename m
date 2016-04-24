From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1 1/1] tipc: fix stale links
 after re-enabling bearer
Date: Sun, 24 Apr 2016 14:36:23 -0400 (EDT)
Message-ID: <20160424.143623.2154778158483252241.davem@davemloft.net>
References: <1461246673-6127-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: parthasarathy.bhuvaragan@ericsson.com
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1461246673-6127-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Date: Thu, 21 Apr 2016 15:51:13 +0200

> Commit 42b18f605fea ("tipc: refactor function tipc_link_timeout()"),
> introduced a bug which prevents sending of probe messages during
> link synchronization phase. This leads to hanging links, if the
> bearer is disabled/enabled after links are up.
> 
> In this commit, we send the probe messages correctly.
> Fixes: 42b18f605fea ("tipc: refactor function tipc_link_timeout()")
> 
> Acked-by: Jon Maloy <jon.maloy@ericsson.com>
> Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>

Please always group a "Fixes: " tag with the other tags.  It is just
another tag like Signed-off-by: and Acked-by: and therefore should be
grouped together with them.

Applied, thanks.

------------------------------------------------------------------------------
Find and fix application performance issues faster with Applications Manager
Applications Manager provides deep performance insights into multiple tiers of
your business applications. It resolves application problems quickly and
reduces your MTTR. Get your free trial!
https://ad.doubleclick.net/ddm/clk/302982198;130105516;z
