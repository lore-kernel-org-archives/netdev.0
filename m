From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/2] netfilter/xt_hashlimit: new feature/algorithm for
 xt_hashlimit
Date: Mon, 4 Sep 2017 13:31:28 +0200
Message-ID: <20170904113128.GA3757@salvia>
References: <1503089939-15938-1-git-send-email-vpai@akamai.com>
 <20170904101433.GA3979@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kadlec@blackhole.kfki.hu, netfilter-devel@vger.kernel.org,
        johunt@akamai.com, fw@strlen.de, netdev@vger.kernel.org,
        pai.vishwain@gmail.com
To: Vishwanath Pai <vpai@akamai.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170904101433.GA3979@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 04, 2017 at 12:14:33PM +0200, Pablo Neira Ayuso wrote:
> On Fri, Aug 18, 2017 at 04:58:59PM -0400, Vishwanath Pai wrote:
> [...]
> > The main difference between the existing algorithm and the new one is
> > that the existing algorithm rate-limits the flow whereas the new
> > algorithm does not. Instead it *classifies* the flow based on whether
> > it is above or below a certain rate. I will demonstrate this with an
> > example below. Let us assume this rule:
> > 
> > iptables -A INPUT -m hashlimit --hashlimit-above 10/s -j new_chain
> > 
> > If the packet rate is 15/s, the existing algorithm would ACCEPT 10
> > packets every second and send 5 packets to "new_chain".
> > 
> > But with the new algorithm, as long as the rate of 15/s is sustained,
> > all packets will continue to match and every packet is sent to new_chain.
> 
> Sounds good, applied, thanks.

BTW, for the record, I have rename this patch title to:

netfilter: xt_hashlimit: add rate match mode

