From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next 0/4] netfilter: rework netfilter ipv6 defrag
Date: Wed, 21 Oct 2015 14:42:45 +0200
Message-ID: <20151021124245.GA10299@salvia>
References: <1445112865-31523-1-git-send-email-fw@strlen.de>
 <CANr6G5zvmj_tL5Pt6-70GQ4dTJXLewX9A4uMGC_0OFzXYQVdew@mail.gmail.com>
 <20151020081716.GH4386@breakpoint.cc>
 <CANr6G5xW7m2SXFiU22pFVD6uvDj5ymX=jZkRJk2vMYQoJykvLw@mail.gmail.com>
 <20151020205306.GK4386@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joe Stringer <joestringer@nicira.com>,
	netfilter-devel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>,
	Andy Zhou <azhou@nicira.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:38874 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751701AbbJUMfu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Oct 2015 08:35:50 -0400
Content-Disposition: inline
In-Reply-To: <20151020205306.GK4386@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 20, 2015 at 10:53:07PM +0200, Florian Westphal wrote:
> Joe Stringer <joestringer@nicira.com> wrote:
> > > Good point.  No, I don't.  Any suggestions?
> > > I can try to just re-target -nf tree (sans patch #2).  Pablo?
> > 
> > The smallest change seems to be adding the nf_ct_frag6_consume_orig()
> > call to OVS, plus the morph logic from patch 3. Alternatively if Pablo
> > is fine with having the series re-targeted, then that sounds
> > reasonable to me too.
> 
> Pablo, your call.
> 
> I would suggest to re-target patches #1 and #3 to nf tree, I can do
> this, just let me know.

It's fairly late, we're on -rc6 so I don't think it's a good idea to
submit a large rework to -nf at this stage.

> Alternative is to just add the nf_ct_frag6_consume_orig call to
> openvswitch and handle that via net tree.
> 
> I can then wait for that change to pop up in nf-next and just resend
> this series (which will then undo that change).

I'd rather get things fixes for the existing code. This would also
allow simple passing back to -stable, then we can move forward discuss
and review your rework with sufficient time.

Let me know, thanks!
