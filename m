From: sandr8 <sandr8_NOSPAM_@crocetta.org>
Subject: should that bugfix wait till 2.6.9? {was Re: Big set of networking
 updates}
Date: Thu, 19 Aug 2004 15:57:58 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4124B1E6.3060808@crocetta.org>
References: <20040818173736.7ad8e58a.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040818173736.7ad8e58a.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:

>ChangeSet@1.1845, 2004-08-15 19:33:16-07:00, kaber@trash.net
>  [PKT_SCHED]: cacheline-align qdisc data in qdisc_create()
>  
>  Signed-off-by: Patrick McHardy <kaber@trash.net>
>  Signed-off-by: David S. Miller <davem@redhat.com>
>
> net/sched/sch_api.c |   21 +++++++++++++--------
> 1 files changed, 13 insertions(+), 8 deletions(-)
>  
>
i was just going to send a similar changeset, since i didn't see any 
discussion so far about that...
this changeset fixes a bug that is in 2.6.8.1 and 2.6.8 as well. today i 
fixed it on my own too, since it was messing up a lot of things...
the handling of the private data belonging to a qdisc was inconsistent. 
the memory allocated was not the memory used and hence its content could 
change.
even worst what happened with a qdisc that had a pointer in its private 
data... god knows what was going on...
isn't it urgent that people patch their kernel? is it possible for them 
to wait till 2.6.9? i had oops regarding ext3 before finding and 
repairing that bug!
cheers
Alessandro
