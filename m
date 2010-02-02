From: Jon Masters <jonathan@jonmasters.org>
Subject: Re: [PATCH] netfilter: per netns nf_conntrack_cachep
Date: Tue, 02 Feb 2010 13:42:03 -0500
Message-ID: <1265136123.2861.200.camel@tonnant>
References: <1264813832.2793.446.camel@tonnant>
	 <1265023437.2848.30.camel@edumazet-laptop>
	 <1265035970.2848.50.camel@edumazet-laptop>
	 <b6fcc0a1002010658j4f52a9b8kf10e4bb07a2f1075@mail.gmail.com>
	 <1265036548.2848.55.camel@edumazet-laptop>
	 <1265108690.2861.118.camel@tonnant> <1265110504.2861.135.camel@tonnant>
	 <1265129192.2861.141.camel@tonnant> <4B685756.8010107@trash.net>
	 <1265130426.2861.158.camel@tonnant>
	 <b6fcc0a1002020958u17315624u4d54d06a413be6bb@mail.gmail.com>
	 <1265134598.2861.191.camel@tonnant>  <4B6870AF.6060109@trash.net>
	 <1265135982.2861.199.camel@tonnant>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1265135982.2861.199.camel@tonnant>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2010-02-02 at 13:39 -0500, Jon Masters wrote:
> On Tue, 2010-02-02 at 19:36 +0100, Patrick McHardy wrote:
> > Jon Masters wrote:
> > > On Tue, 2010-02-02 at 19:58 +0200, Alexey Dobriyan wrote:
> > > 
> > >> Yes, moving to init_net-only function is fine.
> > > 
> > > So moving the "setup up fake conntrack" bits to init_init_net from
> > > init_net still results in the panic, which means that the use count
> > > really is dropping to zero and we really are trying to free it when
> > > using multiple namespaces. Per ns is probably an easier way to go.
> > 
> > Agreed, that will also avoid problems in the future with the
> > ct_net pointer pointing to &init_net. I'll take care of this
> > tommorrow.
> 
> Ok. I'll leave this box running with the hack. I think at the very least
> that this specific issue needs to get fixed and in the stable tree, then
> the other bits (per namespace cachep...) are probably a good idea at the
> same time but that's up to you.

FYI, my box has the quick don't free untracked hack *and* per-ns cachep.
I don't think the latter has anything specific to do with this (though
it needs fixing also), but worth knowing my test is using both.

Back to the podcasts tonight instead of this ;)

Jon.


