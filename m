From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 1/4] netfilter: Add nf_hook_state initializer function.
Date: Tue, 7 Apr 2015 09:45:35 -0700
Message-ID: <20150407164530.GA6008@Alexeis-MBP.westell.com>
References: <20150405.221854.118353659007886815.davem@davemloft.net>
 <1428414081.3965860.250247565.2F639A0C@webmail.messagingengine.com>
 <20150407.115821.441881623894604515.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, pablo@netfilter.org,
	jiri@resnulli.us
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150407.115821.441881623894604515.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 07, 2015 at 11:58:21AM -0400, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Tue, 07 Apr 2015 15:41:21 +0200
> 
> > Minor suggestion:
> > 
> > I think we can return the structure as a whole:
> > 
> > static inline struct nf_hook_state nf_hook_state_init(unsigned int hook,
> > ...).
> > 
> > Being static inline it should not make any difference.
> 
> If by some insane possibility this does not get inlined, this structure
> gets copied to and from the kernel stack on some cpu ABIs in order to
> return it.
> 
> Never return structures from functions, ever.

+1

I bet Dave alluding to insane sparc psABI requirements in that area.
Some horror stories there.
Never return structures. Ever!

