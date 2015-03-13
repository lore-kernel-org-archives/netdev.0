From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] tipc: some optimizations
	and impovements
Date: Fri, 13 Mar 2015 12:52:27 -0400 (EDT)
Message-ID: <20150313.125227.1523044445570081158.davem@davemloft.net>
References: <1426256860-31208-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1426256860-31208-1-git-send-email-jon.maloy@ericsson.com>
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
Date: Fri, 13 Mar 2015 10:27:33 -0400

> The commits in this series contain some relatively simple changes
> that lead to better throughput across TIPC connections. We also make
> changes to the implementation of link transmission queueing and priority
> handling, in order to make the code more comprehensible and maintainable.

I think you should do the SKB linearization changes properly.

Simply do pskb_may_pull() before you inspect any header, and you can
do this everwhere, even your bundling extraction code path.

I also don't think you even need to clone the SKB there either.

Thanks.

------------------------------------------------------------------------------
Dive into the World of Parallel Programming The Go Parallel Website, sponsored
by Intel and developed in partnership with Slashdot Media, is your hub for all
things parallel software development, from weekly thought leadership blogs to
news, videos, case studies, tutorials and more. Take a look and join the 
conversation now. http://goparallel.sourceforge.net/
