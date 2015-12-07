From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: nfnetlink_queue: Unregister pernet subsys in
 case of init failure
Date: Mon, 7 Dec 2015 14:17:46 +0100
Message-ID: <20151207131746.GA27860@salvia>
References: <1449483206-22618-1-git-send-email-kernel@kyup.com>
 <56657BA5.6070303@cogentembedded.com>
 <56658284.9080009@kyup.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	fruggeri@arista.com, kadlec@blackhole.kfki.hu,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, davem@davemloft.net
To: Nikolay Borisov <kernel@kyup.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <56658284.9080009@kyup.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 07, 2015 at 02:58:44PM +0200, Nikolay Borisov wrote:
> 
> 
> On 12/07/2015 02:29 PM, Sergei Shtylyov wrote:
> > Hello.
> > 
> > On 12/07/2015 01:13 PM, Nikolay Borisov wrote:
> > 
> >> Commit 3bfe049807c2403 ('netfilter: nfnetlink_{log,queue}:
> > 
> >    Double quotes please, that's what scripts/checkpatch.pl enforces now.
> > 
> >> Register pernet in first place') reorganised the initialisation
> >> order of the pernet_subsys to avoid "use-before-initialised"
> >> condition. However, in doing so the cleanup logic in nfnetlink_queue
> >> got botched in that the pernet_subsys wasn't cleaned in case
> >> nfnetlink_subsys_register failed. This patch adds the necessary
> >> cleanup routine call.
> >>
> >> Fixes: 3bfe049807c2403 ('netfilter: nfnetlink_{log,queue}: Register
> >>                         pernet in first place')
> > 
> >    Likewise.
> 
> I will resend it with proper quotes (even though I think this is a minor
> issue) but I'd like to first gather some review feedback.

Unless someone spots any other more relevant problem with this, I'll
fix this comestic issues here, no need to resend.

> Also I dunno if this should be marked for stable.

Yes, this qualifies for -stable, will take care of that.

Thanks.
