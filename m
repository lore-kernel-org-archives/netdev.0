From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 6/6] net: move qdisc ingress filtering on top of
 netfilter ingress hooks
Date: Thu, 30 Apr 2015 01:37:23 +0200
Message-ID: <20150429233723.GB7025@acer.localdomain>
References: <1430333589-4940-1-git-send-email-pablo@netfilter.org>
 <1430333589-4940-7-git-send-email-pablo@netfilter.org>
 <CAHA+R7NWeOLTjgAd9xQNcVP=snNOiH0aLy0FyUWzqdH+gVbJ9g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAHA+R7NWeOLTjgAd9xQNcVP=snNOiH0aLy0FyUWzqdH+gVbJ9g@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 29.04, Cong Wang wrote:
> On Wed, Apr 29, 2015 at 11:53 AM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> > diff --git a/net/sched/Kconfig b/net/sched/Kconfig
> > index 2274e72..23b57da 100644
> > --- a/net/sched/Kconfig
> > +++ b/net/sched/Kconfig
> > @@ -312,6 +312,7 @@ config NET_SCH_PIE
> >  config NET_SCH_INGRESS
> >         tristate "Ingress Qdisc"
> >         depends on NET_CLS_ACT
> > +       select NETFILTER_INGRESS
> >         ---help---
> >           Say Y here if you want to use classifiers for incoming packets.
> >           If unsure, say Y.
> 
> 
> So now it impossible to compile ingress Qdics without netfilters...
> 
> (I know you moved them into net/core/, but still they are netfilter API's.)
> 
> Why do we have to mix different layers? IOW, why not just keep TC at L2
> and netfilters at L3 even just w.r.t. API?

Call it what you want, netfilter for most people is the entire infrastructure
built on top of the hooks. We can call it packet hooks if that makes you
happy. And the are infrastructure and not affiliated to any particular
layer.
