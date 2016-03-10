From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC] net: ipv4 -- Introduce ifa limit per net
Date: Thu, 10 Mar 2016 14:03:24 +0300
Message-ID: <20160310110324.GB21154@uranus.lan>
References: <20160309204158.GO2207@uranus.lan>
 <20160309.154725.1921352291794389965.davem@davemloft.net>
 <20160309205746.GQ2207@uranus.lan>
 <20160309.161038.283281065293712589.davem@davemloft.net>
 <20160309211629.GR2207@uranus.lan>
 <20160310102018.GA21154@uranus.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, solar@openwall.com, vvs@virtuozzo.com,
	avagin@virtuozzo.com, xemul@virtuozzo.com, vdavydov@virtuozzo.com,
	khorenko@virtuozzo.com, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>, alexei.starovoitov@gmail.com,
	eric.dumazet@gmail.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160310102018.GA21154@uranus.lan>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 10, 2016 at 01:20:18PM +0300, Cyrill Gorcunov wrote:
> On Thu, Mar 10, 2016 at 12:16:29AM +0300, Cyrill Gorcunov wrote:
> > 
> > Thanks for explanation, Dave! I'll continue on this task tomorrow
> > tryin to implement optimization you proposed.
> 
> OK, here are the results for the preliminary patch with conntrack running
...
>  net/ipv4/devinet.c |   13 ++++++++++++-
>  1 file changed, 12 insertions(+), 1 deletion(-)
> 
> Index: linux-ml.git/net/ipv4/devinet.c
> ===================================================================
> --- linux-ml.git.orig/net/ipv4/devinet.c
> +++ linux-ml.git/net/ipv4/devinet.c
> @@ -403,7 +403,18 @@ no_promotions:
>  	   So that, this order is correct.
>  	 */

This patch is wrong, so drop it please. I'll do another.
