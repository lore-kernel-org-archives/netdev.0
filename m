From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] tipc: move premature
 initilalization of stack variables
Date: Fri, 24 Feb 2017 11:13:48 -0500 (EST)
Message-ID: <20170224.111348.761299008707145759.davem@davemloft.net>
References: <1487866231-23666-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1487866231-23666-1-git-send-email-jon.maloy@ericsson.com>
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
Date: Thu, 23 Feb 2017 11:10:31 -0500

> In the function tipc_rcv() we initialize a couple of stack variables
> from the message header before that same header has been validated.
> In rare cases when the arriving header is non-linar, the validation
> function itself may linearize the buffer by calling skb_may_pull(),
> while the wrongly initialized stack fields are not updated accordingly.
> 
> We fix this in this commit.
> 
> Reported-by: Matthew Wong <mwong@sonusnet.com>
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied.

------------------------------------------------------------------------------
Check out the vibrant tech community on one of the world's most
engaging tech sites, SlashDot.org! http://sdm.link/slashdot
