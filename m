From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [v2 RFC PATCH 2/4] Changes for virtio-net
Date: Fri, 17 Sep 2010 18:50:51 +0530
Message-ID: <OF374A97D5.0C56095D-ON652577A1.00485CC0-652577A1.0049190A@in.ibm.com>
References: <20100917100307.21276.79185.sendpatchset@krkumar2.in.ibm.com>	 <20100917100319.21276.271.sendpatchset@krkumar2.in.ibm.com> <1284719154.3391.84.camel@edumazet-laptop> <OF4A8774FB.F21849D9-ON652577A1.003A4D4E-652577A1.00443FC7@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: anthony@codemonkey.ws, arnd@arndb.de, avi@redhat.com,
	davem@davemloft.net, Eric Dumazet <eric.dumazet@gmail.com>,
	kvm@vger.kernel.org, mst@redhat.com, netdev@vger.kernel.org,
	rusty@rustcorp.com.au
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp06.in.ibm.com ([122.248.162.6]:55604 "EHLO
	e28smtp06.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753799Ab0IQNSa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Sep 2010 09:18:30 -0400
In-Reply-To: <OF4A8774FB.F21849D9-ON652577A1.003A4D4E-652577A1.00443FC7@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Krishna Kumar2/India/IBM@IBMIN
> Sent by: netdev-owner@vger.kernel.org

> > > +
> > >  struct virtnet_info {
> > >     struct virtio_device *vdev;
> > > -   struct virtqueue *rvq, *svq, *cvq;
> > > +   int numtxqs;         /* Number of tx queues */
> > > +   struct send_queue *sq;
> > > +   struct virtqueue *rvq;
> > > +   struct virtqueue *cvq;
> > >     struct net_device *dev;
> >
> > struct napi will probably be dirtied by RX processing
> >
> > You should make sure it doesnt dirty cache line of above (read mostly)
> > fields
>
> I am changing the layout of napi wrt other pointers in
> this patch, though the to-be-submitted RX patch does that.
> Should I do something for this TX-only patch?

Sorry, I think my sentence is not clear! I will make this
change (and also cache-line align the send queues), test
and let you know the result.

Thanks,

- KK

