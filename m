From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 1/1] tipc: don't reset stale
 broadcast send link
Date: Mon, 21 Aug 2017 13:38:11 -0700 (PDT)
Message-ID: <20170821.133811.1648013984195015459.davem@davemloft.net>
References: <1503331170-21745-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ying.xue@windriver.com, netdev@vger.kernel.org,
 tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1503331170-21745-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/options/tipc-discussion>,
 <mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
 <mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Mon, 21 Aug 2017 17:59:30 +0200

> When the broadcast send link after 100 attempts has failed to
> transfer a packet to all peers, we consider it stale, and reset
> it. Thereafter it needs to re-synchronize with the peers, something
> currently done by just resetting and re-establishing all links to
> all peers. This has turned out to be overkill, with potentially
> unwanted consequences for the remaining cluster.
> 
> A closer analysis reveals that this can be done much simpler. When
> this kind of failure happens, for reasons that may lie outside the
> TIPC protocol, it is typically only one peer which is failing to
> receive and acknowledge packets. It is hence sufficient to identify
> and reset the links only to that peer to resolve the situation, without
> having to reset the broadcast link at all. This solution entails a much
> lower risk of negative consequences for the own node as well as for
> the overall cluster.
> 
> We implement this change in this commit.
> 
> Reviewed-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
> Acked-by: Ying Xue <ying.xue@windriver.com>
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied, thanks Jon.

------------------------------------------------------------------------------
Check out the vibrant tech community on one of the world's most
engaging tech sites, Slashdot.org! http://sdm.link/slashdot
