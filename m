From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [v3 RFC PATCH 0/4] Implement multiqueue virtio-net
Date: Thu, 24 Feb 2011 17:18:00 +0530
Message-ID: <OF7580E0BB.9A2AFB5C-ON65257841.003FF6FF-65257841.0040AEC3@in.ibm.com>
References: <20101020085452.15579.76002.sendpatchset@krkumar2.in.ibm.com> <20110222074709.GA18880@verge.net.au> <OFAAA32513.A5D0FB9F-ON65257840.001ACE50-65257840.001D5B76@in.ibm.com> <20110223063915.GA16607@redhat.com> <OFA5C641DD.CCB1702C-ON65257840.0024C22E-65257840.002545D9@in.ibm.com> <20110223155534.GB24146@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: anthony@codemonkey.ws, arnd@arndb.de, avi@redhat.com,
	davem@davemloft.net, eric.dumazet@gmail.com,
	Simon Horman <horms@verge.net.au>, kvm@vger.kernel.org,
	netdev@vger.kernel.org, rusty@rustcorp.com.au
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20110223155534.GB24146@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Michael S. Tsirkin" <mst@redhat.com> wrote on 02/23/2011 09:25:34 PM:

> > Sure, will get a build/test on latest bits and send in 1-2 days.
> >
> > > > The TX-only patch helped the guest TX path but didn't help
> > > > host->guest much (as tested using TCP_MAERTS from the guest).
> > > > But with the TX+RX patch, both directions are getting
> > > > improvements.
> > >
> > > Also, my hope is that with appropriate queue mapping,
> > > we might be able to do away with heuristics to detect
> > > single stream load that TX only code needs.
> >
> > Yes, that whole stuff is removed, and the TX/RX path is
> > unchanged with this patch (thankfully :)
>
> Cool. I was wondering whether in that case, we can
> do without host kernel changes at all,
> and use a separate fd for each TX/RX pair.
> The advantage of that approach is that this way,
> the max fd limit naturally sets an upper bound
> on the amount of resources userspace can use up.
>
> Thoughts?
>
> In any case, pls don't let the above delay
> sending an RFC.

I will look into this also.

Please excuse the delay in sending the patch out faster - my
bits are a little old, so it is taking some time to move to
the latest kernel and get some initial TCP/UDP test results.
I should have it ready by tomorrow.

Thanks,

- KK

