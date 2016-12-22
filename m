From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] tipc: don't send FIN message
 from connectionless socket
Date: Thu, 22 Dec 2016 11:20:57 -0500 (EST)
Message-ID: <20161222.112057.1343936871026993835.davem@davemloft.net>
References: <1482409349-17081-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	viro@zeniv.linux.org.uk
To: jon.maloy@ericsson.com
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1482409349-17081-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Thu, 22 Dec 2016 07:22:29 -0500

> In commit 6f00089c7372 ("tipc: remove SS_DISCONNECTING state") the
> check for socket type is in the wrong place, causing a closing socket
> to always send out a FIN message even when the socket was never
> connected. This is normally harmless, since the destination node for
> such messages most often is zero, and the message will be dropped, but
> it is still a wrong and confusing behavior.
> 
> We fix this in this commit.
> 
> Reviewed-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied.

------------------------------------------------------------------------------
Developer Access Program for Intel Xeon Phi Processors
Access to Intel Xeon Phi processor-based developer platforms.
With one year of Intel Parallel Studio XE.
Training and support from Colfax.
Order your platform today.http://sdm.link/intel
