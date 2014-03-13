From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH net-next v7 0/9] xen-netback: TX grant mapping with
 SKBTX_DEV_ZEROCOPY instead of copy
Date: Thu, 13 Mar 2014 10:43:24 +0000
Message-ID: <1394707404.25873.36.camel@kazak.uk.xensource.com>
References: <1394142511-14827-1-git-send-email-zoltan.kiss@citrix.com>
	 <20140307.160552.282750558679341658.davem@davemloft.net>
	 <531B2B3E.5050800@citrix.com>
	 <20140308.185759.494043114567727021.davem@davemloft.net>
	 <1394638843.3457.11.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <zoltan.kiss@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>,
	<andrew.bennieston@citrix.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394638843.3457.11.camel@kazak.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-03-12 at 15:40 +0000, Ian Campbell wrote:
> On Sat, 2014-03-08 at 18:57 -0500, David Miller wrote:
> > From: Zoltan Kiss <zoltan.kiss@citrix.com>
> > Date: Sat, 8 Mar 2014 14:37:50 +0000
> > 
> > > Maybe you mixed up mine with that? But that's also not eligible to be
> > > applied yet.
> > 
> > I can always revert the series if there are major objections.
> 
> Zoltan -- does this patch series suffer from/expose the confusion
> regarding RING_HAS_UNCONSUMED_REQUESTS which we are discussing
> separately on xen-devel? If the answer is yes then I think this series
> should be reverted for the time being because there seems to be some
> fairly fundamental questions about the semantics of that macro.

The answer was yes but we think this is fixed by "xen-netback: Schedule
NAPI from dealloc thread instead of callback" sent last night. I'll
review that next.

> If the answer is no then I will endeavour to review this version of the
> series ASAP (hopefully tomorrow) and determine if I have any other major
> objections which would warrant a revert.

There was a few things which I would have preferred to see fixed (or
understood) but what's done is done and I don't think any of it warrants
a revert. I commented on a few things which I was sure about or which
I'd like to see fixed in a follow up. I also let a bunch of minor stuff
like coding style nits slip since it doesn't seem worth the churn now
that it is in.

Thanks,
Ian.
