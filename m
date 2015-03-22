From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next] netfilter: bridge: kill nf_bridge_pad
Date: Sun, 22 Mar 2015 20:03:35 +0100
Message-ID: <20150322190335.GA10422@salvia>
References: <1426708531-6343-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1426708531-6343-1-git-send-email-fw@strlen.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 18, 2015 at 08:55:31PM +0100, Florian Westphal wrote:
> The br_netfilter frag output function calls skb_cow_head() so in
> case it needs a larger headroom to e.g. re-add a previously stripped PPPOE
> or VLAN header things will still work (at cost of reallocation).
> 
> We can then move nf_bridge_encap_header_len to br_netfilter.

Applied, thanks.
