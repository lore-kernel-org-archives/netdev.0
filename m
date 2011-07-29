From: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: Fw: [PATCH] sunrpc: use better NUMA affinities
Date: Fri, 29 Jul 2011 06:36:34 -0400
Message-ID: <20110729103634.GA12050@infradead.org>
References: <20110729153207.17af3085@notabene.brown>
 <4E324DB4.7060600@fastmail.fm>
 <1311921035.7845.10.camel@edumazet-laptop>
 <4E3258E1.6020000@fastmail.fm>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, NeilBrown <neilb-l3A5Bk7waGM@public.gmane.org>,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Greg Banks <gnb-97jfqw80gc6171pxa8y+qA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4E3258E1.6020000-97jfqw80gc6171pxa8y+qA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 29, 2011 at 04:53:21PM +1000, Greg Banks wrote:
> >Check commit 94dcf29a11b3d20a (kthread: use kthread_create_on_node()) to
> >see how this strategy already was adopted for ksoftirqd, kworker,
> >migration, and pktgend kthreads.
> 
> Ah, I see.  It's unfortunate that the kthread_create() API ends up
> being passed a CPU number but that's only used to format the name
> and not for sensible things :(

kthread_create doesn't have a cpu argument - it has a printf-like format
string.

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
