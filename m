From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 08/12] netvm: Allow skb allocation to use PFMEMALLOC
 reserves
Date: Fri, 15 Apr 2011 11:44:01 +0100
Message-ID: <20110415104401.GC22688@suse.de>
References: <1302777698-28237-1-git-send-email-mgorman@suse.de>
 <1302777698-28237-9-git-send-email-mgorman@suse.de>
 <20110414.143335.104052252.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: linux-mm@kvack.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, a.p.zijlstra@chello.nl
To: David Miller <davem@davemloft.net>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <20110414.143335.104052252.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 14, 2011 at 02:33:35PM -0700, David Miller wrote:
> From: Mel Gorman <mgorman@suse.de>
> Date: Thu, 14 Apr 2011 11:41:34 +0100
> 
> > +extern int memalloc_socks;
> > +static inline int sk_memalloc_socks(void)
> > +{
> > +	return memalloc_socks;
> > +}
> > +
>  ...
> > +static DEFINE_MUTEX(memalloc_socks_lock);
> > +int memalloc_socks __read_mostly;
> 
> Please use an atomic_t, it has to be more efficient than this mutex
> business.

Will fix.

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
