From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [v3 RFC PATCH 0/4] Implement multiqueue virtio-net
Date: Wed, 23 Feb 2011 12:18:36 +0530
Message-ID: <OFA5C641DD.CCB1702C-ON65257840.0024C22E-65257840.002545D9@in.ibm.com>
References: <20101020085452.15579.76002.sendpatchset@krkumar2.in.ibm.com> <20110222074709.GA18880@verge.net.au> <OFAAA32513.A5D0FB9F-ON65257840.001ACE50-65257840.001D5B76@in.ibm.com> <20110223063915.GA16607@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: anthony@codemonkey.ws, arnd@arndb.de, avi@redhat.com,
	davem@davemloft.net, eric.dumazet@gmail.com,
	Simon Horman <horms@verge.net.au>, kvm@vger.kernel.org,
	netdev@vger.kernel.org, rusty@rustcorp.com.au
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20110223063915.GA16607@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> "Michael S. Tsirkin" <mst@redhat.com> wrote on 02/23/2011 12:09:15 PM:

Hi Michael,

> > Yes. Michael Tsirkin had wanted to see how the MQ RX patch
> > would look like, so I was in the process of getting the two
> > working together. The patch is ready and is being tested.
> > Should I send a RFC patch at this time?
>
> Yes, please do.

Sure, will get a build/test on latest bits and send in 1-2 days.

> > The TX-only patch helped the guest TX path but didn't help
> > host->guest much (as tested using TCP_MAERTS from the guest).
> > But with the TX+RX patch, both directions are getting
> > improvements.
>
> Also, my hope is that with appropriate queue mapping,
> we might be able to do away with heuristics to detect
> single stream load that TX only code needs.

Yes, that whole stuff is removed, and the TX/RX path is
unchanged with this patch (thankfully :)

> > Remote testing is still to be done.
>
> Others might be able to help here once you post the patch.

That's great, will appreciate any help.

Thanks,

- KK

