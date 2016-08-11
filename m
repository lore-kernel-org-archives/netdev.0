From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v1 1/1] tipc: fix variable
 dereference before NULL check
Date: Wed, 10 Aug 2016 17:57:13 -0700 (PDT)
Message-ID: <20160810.175713.50573275943841545.davem@davemloft.net>
References: <1470830854-4072-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: parthasarathy.bhuvaragan@ericsson.com
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1470830854-4072-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
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
Date: Wed, 10 Aug 2016 14:07:34 +0200

> In commit cf6f7e1d5109 ("tipc: dump monitor attributes"),
> I dereferenced a pointer before checking if its valid.
> This is reported by static check Smatch as:
> net/tipc/monitor.c:733 tipc_nl_add_monitor_peer()
>      warn: variable dereferenced before check 'mon' (see line 731)
> 
> In this commit, we check for a valid monitor before proceeding
> with any other operation.
> 
> Fixes: cf6f7e1d5109 ("tipc: dump monitor attributes")
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>

Applied, thank you.

------------------------------------------------------------------------------
What NetFlow Analyzer can do for you? Monitors network bandwidth and traffic
patterns at an interface-level. Reveals which users, apps, and protocols are 
consuming the most bandwidth. Provides multi-vendor support for NetFlow, 
J-Flow, sFlow and other flows. Make informed decisions using capacity 
planning reports. http://sdm.link/zohodev2dev
