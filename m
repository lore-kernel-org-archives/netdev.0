From: "Jayachandran C" <jchandra@digeo.com>
Subject: Re: [RESEND][PATCH] ebtables: clean up vmalloc usage in net/bridge/netfilter/ebtables.c
Date: Thu, 20 Apr 2006 00:32:55 -0700
Message-ID: <20060420073255.GA25288@random.pao.digeo.com>
References: <20060419065025.GE17192@random.pao.digeo.com> <20060419.154126.64036253.davem@davemloft.net> <20060419155925.7aae7d25.akpm@osdl.org> <20060419.160328.128989267.davem@davemloft.net> <20060419161324.02e46449.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bridge@osdl.org, bdschuym@pandora.be, netdev@vger.kernel.org,
	Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from packet.digeo.com ([12.110.80.53]:43166 "EHLO packet.digeo.com")
	by vger.kernel.org with ESMTP id S1750739AbWDTHdz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2006 03:33:55 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060419161324.02e46449.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 19, 2006 at 04:13:24PM -0700, Andrew Morton wrote:
> "David S. Miller" <davem@davemloft.net> wrote:
> >
> > From: Andrew Morton <akpm@osdl.org>
> > Date: Wed, 19 Apr 2006 15:59:25 -0700
> > 
> > > "David S. Miller" <davem@davemloft.net> wrote:
> > > >
> > > > An earlier variant of your patch was applied already, included below.
> > > > You'll need to submit the newer parts relative to the current tree.
> > > 
> > > This is a similar-but-different patch.  It applies OK.
> > > 
> > > I reviewed it (mostly - it's somewhat non-trivial to do this) and queued it
> > > up and was planning on sending it to you for post-2.6.17.
> > 
> > It's at least fixing a few bugs, and the parts which are cleanups
> > undoubtedly should prevent bugs in the future, so I think we
> > should consider it for 2.6.17 right?
> 
> afaict it's just a cleanup, but whatever - I'll send it over now.

The first patch (which is already applied) was a bug fix. This one
is just a clean up, it makes the same clean-up that Andrew did to
the original patch, in other places in the same file.

This is not at all critical, so it can be moved post-2.6.17 without
any problem.

Regards,
JC.
