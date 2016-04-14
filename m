From: Jiri Kosina <jikos@kernel.org>
Subject: Re: Deleting child qdisc doesn't reset parent to default qdisc?
Date: Thu, 14 Apr 2016 18:08:14 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1604141807350.27368@cbobk.fhfr.pm>
References: <alpine.LNX.2.00.1604141638230.27368@cbobk.fhfr.pm> <1460646099.10638.44.camel@edumazet-glaptop3.roam.corp.google.com> <20160414151813.GE3715@orbyte.nwl.cc>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160414151813.GE3715@orbyte.nwl.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 14 Apr 2016, Phil Sutter wrote:

> > > I've came across the behavior where adding a child qdisc and then deleting 
> > > it again makes the networking dysfunctional (I guess that's because all of 
> > > a sudden there is absolutely no working qdisc on the device, although 
> > > there originally was a default one in the parent).
> > > 
> > > In a nutshell, is this expected behavior or bug?
> > 
> > This is the expected behavior.
> 
> OTOH some qdiscs (CBQ, DRR, DSMARK, HFSC, HTB, QFQ) assign the default
> one upon deletion instead of noop_qdisc, hence I would describe
> the situation using the words 'inconsistent' and 'accident' rather than
> 'expected'. :)

Would a patch that'd unify this in a sense that all qdiscs would assign 
the default one upon deletion acceptable?

Thanks,

-- 
Jiri Kosina
SUSE Labs
