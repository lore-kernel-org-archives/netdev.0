From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH nf-next 0/4] netfilter: rework netfilter ipv6 defrag
Date: Wed, 21 Oct 2015 16:50:48 +0200
Message-ID: <20151021145048.GC31323@breakpoint.cc>
References: <1445112865-31523-1-git-send-email-fw@strlen.de>
 <CANr6G5zvmj_tL5Pt6-70GQ4dTJXLewX9A4uMGC_0OFzXYQVdew@mail.gmail.com>
 <20151020081716.GH4386@breakpoint.cc>
 <CANr6G5xW7m2SXFiU22pFVD6uvDj5ymX=jZkRJk2vMYQoJykvLw@mail.gmail.com>
 <20151020205306.GK4386@breakpoint.cc>
 <20151021124245.GA10299@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	Joe Stringer <joestringer@nicira.com>,
	netfilter-devel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>,
	Andy Zhou <azhou@nicira.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:39915 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750905AbbJUOuv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 10:50:51 -0400
Content-Disposition: inline
In-Reply-To: <20151021124245.GA10299@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> > I can then wait for that change to pop up in nf-next and just resend
> > this series (which will then undo that change).
> 
> I'd rather get things fixes for the existing code. This would also
> allow simple passing back to -stable, then we can move forward discuss
> and review your rework with sufficient time.

Joe, could you take care of this and submit a OVS fix to net tree?

(just add that call to nf_ct_frag6_consume_orig and take
 the morph change directly into the OVS callpath)

I will then resubmit all of this at some later point.

Thanks.
