From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH rfc] netfilter: two xtables matches
Date: Fri, 7 Dec 2012 08:22:49 +0100
Message-ID: <20121207072249.GA10911@1984>
References: <1354735339-13402-1-git-send-email-willemb@google.com>
 <CA+FuTSeYvcdtNf7N=POD+RzsE01+WVsub6F_nqbn06RZyoWx8w@mail.gmail.com>
 <alpine.LNX.2.01.1212052100190.30908@nerf07.vanv.qr>
 <20121206052246.GA2905@1984>
 <CA+FuTSf+fh21koZRJ_ZDsr8yiiwcw2-pJ4uTyS2pOHZGdBM1-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan Engelhardt <jengelh@inai.de>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: Willem de Bruijn <willemb@google.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+FuTSf+fh21koZRJ_ZDsr8yiiwcw2-pJ4uTyS2pOHZGdBM1-w@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 06, 2012 at 04:12:10PM -0500, Willem de Bruijn wrote:
> On Thu, Dec 6, 2012 at 12:22 AM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> > On Wed, Dec 05, 2012 at 09:00:36PM +0100, Jan Engelhardt wrote:
> >> On Wednesday 2012-12-05 20:28, Willem de Bruijn wrote:
> >>
> >> >Somehow, the first part of this email went missing. Not critical,
> >> >but for completeness:
> >> >
> >> >These two patches each add an xtables match.
> >> >
> >> >The xt_priority match is a straighforward addition in the style of
> >> >xt_mark, adding the option to filter on one more sk_buff field. I
> >> >have an immediate application for this. The amount of code (in
> >> >kernel + userspace) to add a single check proved quite large.
> >>
> >> Hm so yeah, can't we just place this in xt_mark.c?
> >
> > I don't feel this belongs to xt_mark at all.
> 
> Do you have other concerns, or can I resubmit as is for merging in a
> few days if no one raises additional issues?
> 
> For this and netfilter changes in general: should these patches be
> against git://1984.lsi.us.es/nf-next instead of net-next? This patch
> likely applies cleanly there, but I haven't tried yet. Thanks.

Please, against nf-next since this has to go throuh the netfilter
tree.
