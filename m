From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC PATCH 0/4] Implement multiqueue virtio-net
Date: Wed, 8 Sep 2010 14:58:46 +0530
Message-ID: <OF7E044823.F6B1C64E-ON65257798.00338331-65257798.0033DC0D@in.ibm.com>
References: <20100908072859.23769.97363.sendpatchset@krkumar2.in.ibm.com> <20100908081326.GD23051@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: anthony@codemonkey.ws, davem@davemloft.net, kvm@vger.kernel.org,
	netdev@vger.kernel.org, rusty@rustcorp.com.au
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20100908081326.GD23051@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Michael,

"Michael S. Tsirkin" <mst@redhat.com> wrote on 09/08/2010 01:43:26 PM:

> On Wed, Sep 08, 2010 at 12:58:59PM +0530, Krishna Kumar wrote:
> > 1. mq RX patch is also complete - plan to submit once TX is OK.
>
> It's good that you split patches, I think it would be interesting to see
> the RX patches at least once to complete the picture.
> You could make it a separate patchset, tag them as RFC.

OK, I need to re-do some parts of it, since I started the TX only
branch a couple of weeks earlier and the RX side is outdated. I
will try to send that out in the next couple of days, as you say
it will help to complete the picture. Reasons to send it only TX
now:

- Reduce size of patch and complexity
- I didn't get much improvement on multiple RX patch (netperf from
  host -> guest), so needed some time to figure out the reason and
  fix it.

Thanks,

- KK

