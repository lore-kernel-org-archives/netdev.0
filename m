From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/4] tipc: emulate multicast
	through replication
Date: Fri, 20 Jan 2017 12:10:34 -0500 (EST)
Message-ID: <20170120.121034.1107664043634334940.davem@davemloft.net>
References: <1484765453-16258-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1484765453-16258-1-git-send-email-jon.maloy@ericsson.com>
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
Date: Wed, 18 Jan 2017 13:50:49 -0500

> TIPC multicast messages are currently distributed via L2 broadcast
> or IP multicast to all nodes in the cluster, irrespective of the
> number of real destinations of the message.
> 
> In this series we introduce an option to transport messages via
> replication ("replicast") across a selected number of unicast links,
> instead of relying on the underlying media. This option is used when
> true broadcast/multicast is not supported by the media, or when the
> number of true destinations is much smaller than the cluster size.

Series applied, thanks Jon.

------------------------------------------------------------------------------
Check out the vibrant tech community on one of the world's most
engaging tech sites, SlashDot.org! http://sdm.link/slashdot
