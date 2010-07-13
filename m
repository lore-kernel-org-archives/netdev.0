From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: Re: [PATCH] netfilter: xtables: userspace notification target
Date: Tue, 13 Jul 2010 16:24:33 +0300
Message-ID: <1279027474.12673.61.camel@chilepepper>
References: <20100713001115.GA3751@sortiz-mobl>
	 <AANLkTil2EgQbzUqYNHAYpIWJvyyE6AWq1TpvxrqVsD7k@mail.gmail.com>
	 <4C3C28EC.2000302@netfilter.org> <1279016596.12673.11.camel@chilepepper>
	 <alpine.LSU.2.01.1007131349120.778@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ext Pablo Neira Ayuso <pablo@netfilter.org>,
	Changli Gao <xiaosuo@gmail.com>,
	Samuel Ortiz <sameo@linux.intel.com>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>
To: ext Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.01.1007131349120.778@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2010-07-13 at 13:49 +0200, ext Jan Engelhardt wrote:
> On Tuesday 2010-07-13 12:23, Luciano Coelho wrote:
> >> 
> >> Indeed, this looks to me like something that you can do with NFLOG and
> >> some combination of matches.
> >
> >Is it possible to have the NFLOG send only one notification to the
> >userspace? In the example above, once the quota exceeds, the userspace
> >will be notified of every packet arriving, won't it?  That would cause
> >unnecessary processing in the userspace.
> >
> >The userspace could remove the rule when it gets the first notification
> >and only add it again when it needs to get the information again (as a
> >"toggle" functionality), but I think that would take too long and there
> >would be several packets going through before the rule could be removed.
> 
> With xt_condition that should not be a problem
> (-A INPUT -m condition --name ruleXYZ -j NFLOG..)
> This is settable through procfs.

Right.  I didn't know about the condition match, because I can't see it
either on net-next-2.6 nor on nf-next-2.6.  I found your patch in the
netfilter-devel archives, though.  Any idea when it will be applied?


-- 
Cheers,
Luca.

