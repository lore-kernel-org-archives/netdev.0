From: David Miller <davem@davemloft.net>
Subject: Re: tipc on sparc32
Date: Tue, 02 Sep 2008 23:12:01 -0700 (PDT)
Message-ID: <20080902.231201.184658566.davem@davemloft.net>
References: <20080902224059.70a182ba.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: akpm@linux-foundation.org
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <20080902224059.70a182ba.akpm@linux-foundation.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Sender: tipc-discussion-bounces@lists.sourceforge.net
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>
Date: Tue, 2 Sep 2008 22:40:59 -0700

> sparc32 allmodconfig:
> 
> In file included from net/tipc/link.h:43,
>                  from net/tipc/bcast.c:41:
> net/tipc/node.h:71: error: redefinition of 'struct node'
> 
> sparc32 likes catching code which uses insufficiently cautiously chosen
> identifiers.  dlm is presently blowing up on sparc32 because it has a
> to_node() function.
> 
> Arguably, sparc32 should be fixed, but I'd suggest that random bits of
> networking code should not be using identifiers as generic-sounding as "node".

I'll fix sparc for the time being, thanks.

-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
