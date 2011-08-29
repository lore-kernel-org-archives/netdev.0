From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Subject: RE: [PATCH 19/24] sunrpc: Remove unnecessary OOM logging messages
Date: Mon, 29 Aug 2011 16:25:08 -0700
Message-ID: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430AEB4FAF@SACMVEXC2-PRD.hq.netapp.com>
References: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430AEB4EE9@SACMVEXC2-PRD.hq.netapp.com><20110829.143751.1153162956919885670.davem@davemloft.net><4E5C0AB3.90401@panasas.com> <20110829.180348.1774953636752413432.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <joe@perches.com>, <bfields@fieldses.org>, <neilb@suse.de>,
	<linux-nfs@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>, <bharrosh@panasas.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <20110829.180348.1774953636752413432.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Monday, August 29, 2011 6:04 PM
> To: bharrosh@panasas.com
> Cc: Myklebust, Trond; joe@perches.com; bfields@fieldses.org;
> neilb@suse.de; linux-nfs@vger.kernel.org; netdev@vger.kernel.org;
> linux-kernel@vger.kernel.org
> Subject: Re: [PATCH 19/24] sunrpc: Remove unnecessary OOM logging
> messages
> 
> From: Boaz Harrosh <bharrosh@panasas.com>
> Date: Mon, 29 Aug 2011 14:54:59 -0700
> 
> > I have a question about that. Are the dprints going to show the
stack
> backtrace?
> 
> Yes, OOMs give full stack backtraces.
> 
> > If yes above? then I'm not sure I like it either, because am I'll be
> getting a full
> > stack backtrace for every failed allocation?
> 
> They've been doing this for years, so obviously they haven't bothered
> you
> enough to care up to this point.
> 
> All of this pushback is pure uneducated noise, please stop blocking
> progress
> with poorly informed objections.

I can see that slub.c has the slab_out_of_memory() function that
(although ratelimited) warns you if the allocation failed. However I
can't find any equivalent for slab.c or slob.c.

Trond
