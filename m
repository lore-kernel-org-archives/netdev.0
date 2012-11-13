From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 0/3] netfilter updates for net-next
Date: Tue, 13 Nov 2012 13:40:02 +0100
Message-ID: <20121113124002.GA5350@1984>
References: <1352765203-4160-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1352765203-4160-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 13, 2012 at 01:06:40AM +0100, pablo@netfilter.org wrote:
> From: Pablo Neira Ayuso <pablo@netfilter.org>
> 
> Hi David,
> 
> The following three patches contain updates for your net-next tree,
> they include:
> 
> * Little cleanup for IPVS the use of a strange notation to assign the
>   conntrack object, from Alan Cox.
> 
> * getsockopt support to obtain the original IPv6 address after NAT,
>   similar to the one that IPv4 provides, from Florian Westphal.
> 
> * Another little cleanup for nf_nat to save a couple of lines by using
>   PTR_RET, from Wu Fengguang.

Please, hold on with this pull request. We need a follow-up patch to
resolve an issue regarding the getsockopt to obtain original address
with IPv6 NAT.

I'll send you a new pull request.

Sorry for the inconvenience.
