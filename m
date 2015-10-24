From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/16] tipc: improve
	broadcast implementation
Date: Sat, 24 Oct 2015 07:02:47 -0700 (PDT)
Message-ID: <20151024.070247.207024292559101493.davem@davemloft.net>
References: <1445518308-26200-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1445518308-26200-1-git-send-email-jon.maloy@ericsson.com>
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
Date: Thu, 22 Oct 2015 08:51:32 -0400

> The TIPC broadcast link implementation is currently complex and hard to
> follow. It also incurs some amount of code and structure duplication,
> something that can be reduced significantly with a little effort.
> 
> This commit series introduces a number of improvements which address
> both the locking structure, the code/structure duplication issue, and
> the overall readbility of the code.
> 
> The series consists of three main parts:
> 
> 1-7: Adaptation to the new link structure, and preparation for the next
>      step. In particular, we want the broadcast transmission link to
>      have a life cycle that is longer than any of its potential (unicast
>      and broadcast receive links) users. This eliminates the need to
>      always test for the presence of this link before accessing it.
> 
> 8-10: This is what is really new in this series. Commit #9 is by far
>       the largest and most important one, because it moves most of
>       the broadcast functionality into link.c, partially reusing the
>       fields and functionality of the unicast link. The removal of
>       the "node_map" infrastructure in commit #10 is also an important
>       achievement.
> 
> 11-16: Some improvements leveraging the changes made in the previous
>        commits.
> 
> The series needs commit 53387c4e22ac ("tipc: extend broadcast link window size")
> and commit e53567948f82 ("tipc: conditionally expand buffer headroom over udp tunnel")
> which are both present in 'net' but not yet in 'net-next', to apply cleanly.

Series applied, thanks Jon.

And I really appreciate the exact explanation of what this series
depended upon.

Thanks again.

------------------------------------------------------------------------------
