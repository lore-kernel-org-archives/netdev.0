From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tipc: fix out of bounds
	indexing
Date: Mon, 28 Apr 2014 14:49:26 -0400 (EDT)
Message-ID: <20140428.144926.436860974988702953.davem@davemloft.net>
References: <1398666009-1334-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: erik.hugne@ericsson.com
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1398666009-1334-1-git-send-email-erik.hugne@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: <erik.hugne@ericsson.com>
Date: Mon, 28 Apr 2014 08:20:09 +0200

> From: Erik Hugne <erik.hugne@ericsson.com>
> 
> Commit 78acb1f9b898e85fa2c1e28e700b54b66b288e8d ("tipc: add
> ioctl to fetch link names") introduced a buffer overflow bug where
> specially crafted ioctl requests could cause out-of-bounds indexing
> of the node->links array. This was caused by an incorrect check vs
> MAX_BEARERS, and the static code checker complaint is:
> net/tipc/node.c:459 tipc_node_get_linkname() error: buffer overflow 'node->links' 2 <= 2
> 
> Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.

------------------------------------------------------------------------------
"Accelerate Dev Cycles with Automated Cross-Browser Testing - For FREE
Instantly run your Selenium tests across 300+ browser/OS combos.  Get 
unparalleled scalability from the best Selenium testing platform available.
Simple to use. Nothing to install. Get started now for free."
http://p.sf.net/sfu/SauceLabs
