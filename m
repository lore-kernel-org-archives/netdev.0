From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 0/4] netfilter fixes for 3.4-rc7
Date: Tue, 15 May 2012 01:25:14 +0200
Message-ID: <20120514232514.GA16660@1984>
References: <1336996023-20249-1-git-send-email-pablo@netfilter.org>
 <20120514.185607.1967456974676336550.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120514.185607.1967456974676336550.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 14, 2012 at 06:56:07PM -0400, David Miller wrote:
> From: pablo@netfilter.org
> Date: Mon, 14 May 2012 13:46:59 +0200
> 
> > * One fix for possible timeout overflow for ipset, from Jozsef
> >   Kadlecsik.
> > 
> > * One fix to ensure that hash size is correct, again for ipset
> >   from Jozsef Kadlecsik.
> > 
> > * Removal of redundant include in xt_CT from Eldad Zack.
> > 
> > * Fix for wrong usage of MODULE_ALIAS_NFCT_HELPER in nf_ct_h323
> >   helper from myself.
> 
> I don't consider any of these appropriate this late in the -RC
> series.
> 
> They don't fix major regressions seen by many users.
> 
> And the duplicate header include is extremely out-of-scope and
> inappropriate.
> 
> Sorry.

No problem, I'll schedule those for net-next.
