From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] Reduce netfilter memory use on MP systems
Date: Mon, 7 Feb 2005 20:10:28 +0100
Message-ID: <20050207191028.GF31482@wotan.suse.de>
References: <20050204140900.GD2518@wotan.suse.de>
	<20050207183125.GJ10011@obroa-skai.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Harald Welte <laforge@netfilter.org>, Andi Kleen <ak@suse.de>,
	netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org
Content-Disposition: inline
In-Reply-To: <20050207183125.GJ10011@obroa-skai.de.gnumonks.org>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

> Also wrt. your vmalloc issues, I think there are floating around some
> patches which replace our vmalloc use by __get_free_pages() anyway.

Don't think they're needed (unless you want it for other reasons). 
The vmalloc limit is clearly a bug in itself and will be surely fixed.

-Andi
