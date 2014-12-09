From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tipc: avoid double lock
	'spin_lock:&seq->lock'
Date: Tue, 09 Dec 2014 18:27:23 -0500 (EST)
Message-ID: <20141209.182723.1158512640709971739.davem@davemloft.net>
References: <1418109476-2006-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net, dan.carpenter@oracle.com
To: ying.xue@windriver.com
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1418109476-2006-1-git-send-email-ying.xue@windriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Ying Xue <ying.xue@windriver.com>
Date: Tue, 9 Dec 2014 15:17:56 +0800

> The commit fb9962f3cefe ("tipc: ensure all name sequences are properly
> protected with its lock") involves below errors:
> 
> net/tipc/name_table.c:980 tipc_purge_publications() error: double lock 'spin_lock:&seq->lock'
> 
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Ying Xue <ying.xue@windriver.com>

Applied.

------------------------------------------------------------------------------
Download BIRT iHub F-Type - The Free Enterprise-Grade BIRT Server
from Actuate! Instantly Supercharge Your Business Reports and Dashboards
with Interactivity, Sharing, Native Excel Exports, App Integration & more
Get technology previously reserved for billion-dollar corporations, FREE
http://pubads.g.doubleclick.net/gampad/clk?id=164703151&iu=/4140/ostg.clktrk
