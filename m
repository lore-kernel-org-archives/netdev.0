From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 6/6] netfilter: nf_conntrack: fix early_drop with
 reliable event delivery
Date: Wed, 7 Mar 2012 14:19:20 +0100
Message-ID: <20120307131920.GA6499@1984>
References: <1331032975-5303-1-git-send-email-pablo@netfilter.org>
 <1331032975-5303-7-git-send-email-pablo@netfilter.org>
 <20120306.151618.683601515842945468.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120306.151618.683601515842945468.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 06, 2012 at 03:16:18PM -0500, David Miller wrote:
> From: pablo@netfilter.org
> Date: Tue,  6 Mar 2012 12:22:55 +0100
> 
> > From: Pablo Neira Ayuso <pablo@netfilter.org>
> > 
> > If reliable event delivery is enabled and ctnetlink fails to deliver
> > the destroy event in early_drop, the conntrack subsystem cannot
> > drop any the candidate flow that was planned to be evicted.
> > 
> > Reported-by: Kerin Millar <kerframil@gmail.com>
> > Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> 
> Applied.
> 
> > +		/* Check if we indeed killed this entry. Reliable event
> > +		   delivery may have inserted it into the dying list. */
> > +		if (test_bit(IPS_DYING_BIT, &ct->status)) {
> 
> Please don't allow misformatted comments like this into your
> tree next time, this should be:
> 
> 		/* Check if we indeed killed this entry. Reliable event
> 		 * delivery may have inserted it into the dying list.
> 		 */

Thanks for spotting this.

Will in the future (probably some patches that I took for net-next
may not follow this format either, but for upcoming patches I will).
