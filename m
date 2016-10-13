From: David Miller <davem@davemloft.net>
Subject: Re: [patch] tipc: info leak in
	__tipc_nl_add_udp_addr()
Date: Thu, 13 Oct 2016 12:10:40 -0400 (EDT)
Message-ID: <20161013.121040.414946493107087613.davem@davemloft.net>
References: <20161013080606.GA3389@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net, richard.alpe@ericsson.com
To: dan.carpenter@oracle.com
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <20161013080606.GA3389@mwanda>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 13 Oct 2016 11:06:06 +0300

> We should clear out the padding and unused struct members so that we
> don't expose stack information to userspace.
> 
> Fixes: fdb3accc2c15 ('tipc: add the ability to get UDP options via netlink')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks.

------------------------------------------------------------------------------
Check out the vibrant tech community on one of the world's most 
engaging tech sites, SlashDot.org! http://sdm.link/slashdot
