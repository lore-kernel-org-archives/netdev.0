From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: nf_tables: 64bit stats need some extra
 synchronization
Date: Mon, 14 Jul 2014 12:19:26 +0200
Message-ID: <20140714101926.GA18398@salvia>
References: <1404911646.3515.26.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netfilter-devel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1404911646.3515.26.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 09, 2014 at 03:14:06PM +0200, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Use generic u64_stats_sync infrastructure to get proper 64bit stats,
> even on 32bit arches, at no extra cost for 64bit arches.
> 
> Without this fix, 32bit arches can have some wrong counters at the time
> the carry is propagated into upper word.

Applied, thanks for spotting this Eric.
