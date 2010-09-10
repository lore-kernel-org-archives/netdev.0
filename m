From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC PATCH 0/4] Implement multiqueue virtio-net
Date: Fri, 10 Sep 2010 10:49:40 +0530
Message-ID: <OFD6515F67.3E6B35FB-ON6525779A.001910C3-6525779A.001D0C88@in.ibm.com>
References: <20100908072859.23769.97363.sendpatchset@krkumar2.in.ibm.com> <20100908081011.GC23051@redhat.com> <OF70542242.6CAA236A-ON65257798.0044A4E0-65257798.005C0E7C@LocalDomain> <OF8043B2B7.7048D739-ON65257799.0021A2EE-65257799.00356B3E@in.ibm.com> <4C896708.1050607@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: anthony@codemonkey.ws, davem@davemloft.net, kvm@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	rusty@rustcorp.com.au
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4C896708.1050607@us.ibm.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sridhar Samudrala <sri@us.ibm.com> wrote on 09/10/2010 04:30:24 AM:

> I remember seeing similar issue when using a separate vhost thread for
> TX and
> RX queues.  Basically, we should have the same vhost thread process a
> TCP flow
> in both directions. I guess this allows the data and ACKs to be
> processed in sync.

I was trying that by sharing threads between rx and tx[0], but
that didn't work either since guest rarely picks txq=0. I was
able to get reasonable single stream performance by pinning
vhosts to the same cpu.

Thanks,

- KK

