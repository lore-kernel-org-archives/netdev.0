From: "Patrick Mullaney" <pmullaney@novell.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Thu, 02 Apr 2009 08:14:34 -0600
Message-ID: <49D473EA020000C700056627@lucius.provo.novell.com>
References: <49D469D2020000A100045FA1@lucius.provo.novell.com>
 <49D473EA020000C700056627@lucius.provo.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <anthony@codemonkey.ws>, <andi@firstfloor.org>,
	<herbert@gondor.apana.org.au>,
	"Gregory Haskins" <GHaskins@novell.com>,
	"Peter Morreale" <PMorreale@novell.com>, <rusty@rustcorp.com.au>,
	<agraf@suse.de>, <kvm@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: <avi@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <49D473EA020000C700056627@lucius.provo.novell.com>
Content-Disposition: inline
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2009-04-02 at 16:27 +0300, Avi Kivity wrote:

> 
> virtio is a stable ABI.
> 
> > However, theres still the possibility we can make this work in an ABI
> > friendly way with cap-bits, or other such features.  For instance, the
> > virtio-net driver could register both with pci and vbus-proxy and
> > instantiate a device with a slightly different ops structure for each or
> > something.  Alternatively we could write a host-side shim to expose vbus
> > devices as pci devices or something like that.
> >   
> 
> Sounds complicated...
> 

IMO, it doesn't sound anymore complicated than making virtio support the
concepts already provided by vbus/venet-tap driver. Isn't there already
precedent for alternative approaches co-existing and having the users
decide which is the most appropriate for their use case? Switching
drivers in order to improve latency for a certain class of applications
would seem like something latency sensitive users would be more than
willing to do. I'd like to point out 2 things. Greg has offered help
in moving virtio into the vbus infrastructure. The vbus infrastructure
is a large part of what is being proposed here.


