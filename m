From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v1 1/1] tipc: allocate user memory
 with GFP_KERNEL flag
Date: Mon, 16 Jan 2017 13:32:05 -0500 (EST)
Message-ID: <20170116.133205.742000535333252859.davem@davemloft.net>
References: <1484318785-20749-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	jon.maloy@ericsson.com
To: parthasarathy.bhuvaragan@ericsson.com
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1484318785-20749-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
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
Date: Fri, 13 Jan 2017 15:46:25 +0100

> Until now, we allocate memory always with GFP_ATOMIC flag.
> When the system is under memory pressure and a user tries to send,
> the send fails due to low memory. However, the user application
> can wait for free memory if we allocate it using GFP_KERNEL flag.
> 
> In this commit, we use allocate memory with GFP_KERNEL for all user
> allocation.
> 
> Reported-by: Rune Torgersen <runet@innovsys.com>
> Acked-by: Jon Maloy <jon.maloy@ericsson.com>
> Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>

Applied.

------------------------------------------------------------------------------
Check out the vibrant tech community on one of the world's most
engaging tech sites, SlashDot.org! http://sdm.link/slashdot
