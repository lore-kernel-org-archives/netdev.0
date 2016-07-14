From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next v2 1/3] netfilter: bridge: add and use
 br_nf_hook_thresh
Date: Thu, 14 Jul 2016 19:17:27 +0200
Message-ID: <20160714171727.GA1244@salvia>
References: <1468337541-23930-1-git-send-email-aconole@bytheb.org>
 <1468337541-23930-2-git-send-email-aconole@bytheb.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Florian Westphal <fw@strlen.de>
To: Aaron Conole <aconole@bytheb.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1468337541-23930-2-git-send-email-aconole@bytheb.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 12, 2016 at 11:32:19AM -0400, Aaron Conole wrote:
> +/* recursively invokes nf_hook_slow (again), skipping already-called
> + * hooks (< NF_BR_PRI_BRNF).
> + *
> + * Called with rcu read lock held.
> + */
> +int br_nf_hook_thresh(unsigned int hook, struct net *net,
> +		      struct sock *sk, struct sk_buff *skb,
> +		      struct net_device *indev,
> +		      struct net_device *outdev,
> +		      int (*okfn)(struct net *, struct sock *,
> +				  struct sk_buf *))
                                         ^^^^^^

This doesn't compile. Please, make sure patches compile independently
so we make sure git bisectability doesn't break. Thanks.
