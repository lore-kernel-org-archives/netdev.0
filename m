From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] virtio-net: Read MAC only after initializing MSI-X
Date: Mon, 19 Sep 2011 13:05:17 +0930
Message-ID: <871uvdryq2.fsf@rustcorp.com.au>
References: <1313225461-24458-1-git-send-email-levinsasha928@gmail.com> <20110819152335.GA19489@redhat.com> <1313771587.12243.16.camel@lappy> <20110820200043.GB5276@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>,
	Sasha Levin <levinsasha928@gmail.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20110820200043.GB5276@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 20 Aug 2011 23:00:44 +0300, "Michael S. Tsirkin" <mst@redhat.com> wrote:
> On Fri, Aug 19, 2011 at 07:33:07PM +0300, Sasha Levin wrote:
> > Maybe this is better solved by copying the way it was done in PCI itself
> > with capability linked list?
> 
> There are any number of ways to lay out the structure.  I went for what
> seemed a simplest one.  For MSI-X the train has left the station.  We
> can probably still tweak where the high 32 bit features
> for 64 bit features are.  No idea if it's worth it.

Sorry, this has been in the back of my mind.  I think it's a good idea;
can we use the capability linked list for pre-device specific stuff from
now on?

Thanks,
Rusty.
