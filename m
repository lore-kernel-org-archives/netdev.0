From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC] MASQUERADE / policy routing ("Route send us somewhere
 else")
Date: Mon, 30 Aug 2004 19:19:15 -0700
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <20040830191915.04d49268.davem@davemloft.net>
References: <20040830201957.GY5824@sunbeam.de.gnumonks.org>
	<20040830140729.7309ecc0.davem@davemloft.net>
	<20040831013841.GA5824@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, rusty@rustcorp.com.au,
	netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20040831013841.GA5824@sunbeam.de.gnumonks.org>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

On Tue, 31 Aug 2004 03:38:42 +0200
Harald Welte <laforge@netfilter.org> wrote:

> Thanks for your quick reply, Dave.

Was this one quicker? :)

> > # It can screw up the things a lot. 
> 
> does not really give me an understanding of why and where it might screw
> up. I really want  to fully understand this issue before proposing any
> change.
> 
> > # In this context, if you want to be sure that packet will go out
> > # expected interface you do plain lookup and drop packet if it gave
> > # you some strange route.
> 
> That is the presumption I am about to challenge.  Is the 'original'
> interface really the one we want in this case? 

Good question.

What Alexey appears to be objecting to, exactly, is how Rusty added
a specific output device specifier to the flow key for route lookup.

I think the check can be removed.  If someone screams, we'll revisit.
