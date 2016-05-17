From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tipc: check nl sock before
 parsing nested attributes
Date: Mon, 16 May 2016 21:59:21 -0400 (EDT)
Message-ID: <20160516.215921.884864359703583643.davem@davemloft.net>
References: <1463390094-9235-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	eric.dumazet@gmail.com, sploving1@gmail.com
To: richard.alpe@ericsson.com
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1463390094-9235-1-git-send-email-richard.alpe@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Richard Alpe <richard.alpe@ericsson.com>
Date: Mon, 16 May 2016 11:14:54 +0200

> Make sure the socket for which the user is listing publication exists
> before parsing the socket netlink attributes.
> 
> Prior to this patch a call without any socket caused a NULL pointer
> dereference in tipc_nl_publ_dump().
> 
> Tested-and-reported-by: Baozeng Ding <sploving1@gmail.com>
> Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>

Applied and queued up for -stable.

------------------------------------------------------------------------------
Mobile security can be enabling, not merely restricting. Employees who
bring their own devices (BYOD) to work are irked by the imposition of MDM
restrictions. Mobile Device Manager Plus allows you to control only the
apps on BYO-devices by containerizing them, leaving personal data untouched!
https://ad.doubleclick.net/ddm/clk/304595813;131938128;j
