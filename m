From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH 1/4] Add a new API to virtio-pci
Date: Sun, 12 Sep 2010 13:46:37 +0200
Message-ID: <20100912114637.GB22982@redhat.com>
References: <20100908072859.23769.97363.sendpatchset@krkumar2.in.ibm.com>
 <201009091319.40274.rusty@rustcorp.com.au>
 <OFB29E6C59.96686002-ON65257799.00174D50-65257799.001D6F7B@in.ibm.com>
 <201009092144.26484.rusty@rustcorp.com.au>
 <OF371A1B54.B0F5B4A1-ON65257799.00491939-65257799.004BBB65@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>, anthony@codemonkey.ws,
	davem@davemloft.net, kvm@vger.kernel.org, netdev@vger.kernel.org
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <OF371A1B54.B0F5B4A1-ON65257799.00491939-65257799.004BBB65@in.ibm.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 09, 2010 at 07:19:33PM +0530, Krishna Kumar2 wrote:
> Unfortunately I need a
> constant in vhost for now.

Maybe not even that: you create multiple vhost-net
devices so vhost-net in kernel does not care about these
either, right? So this can be just part of vhost_net.h
in qemu.
