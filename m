From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] tipc: purge backlog queue
 counters when broadcast link is reset
Date: Sun, 28 Jun 2015 16:43:26 -0700 (PDT)
Message-ID: <20150628.164326.1697483508955370526.davem@davemloft.net>
References: <1435499084-29332-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1435499084-29332-1-git-send-email-jon.maloy@ericsson.com>
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
Date: Sun, 28 Jun 2015 09:44:44 -0400

> In commit 1f66d161ab3d8b518903fa6c3f9c1f48d6919e74
> ("tipc: introduce starvation free send algorithm")
> we introduced a counter per priority level for buffers
> in the link backlog queue. We also introduced a new
> function tipc_link_purge_backlog(), to reset these
> counters to zero when the link is reset.
> 
> Unfortunately, we missed to call this function when
> the broadcast link is reset, with the result that the
> values of these counters might be permanently skewed
> when new nodes are attached. This may in the worst case
> lead to permananent, but spurious, broadcast link
> congestion, where no broadcast packets can be sent at
> all.
> 
> We fix this bug with this commit.
> 
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied, thanks.

------------------------------------------------------------------------------
Monitor 25 network devices or servers for free with OpManager!
OpManager is web-based network management software that monitors 
network devices and physical & virtual servers, alerts via email & sms 
for fault. Monitor 25 devices for free with no restriction. Download now
http://ad.doubleclick.net/ddm/clk/292181274;119417398;o
