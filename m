From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH v7 01/19] Add a new structure for skb buffer from
	external.
Date: Sun, 20 Jun 2010 14:11:24 +0300
Message-ID: <20100620111124.GB5285@redhat.com>
References: <F2E9EB7348B8264F86B6AB8151CE2D791210AA4475@shsmsx502.ccr.corp.intel.com> <F2E9EB7348B8264F86B6AB8151CE2D79134F9AA999@shsmsx502.ccr.corp.intel.com> <20100617112119.GB1515@gondor.apana.org.au> <F2E9EB7348B8264F86B6AB8151CE2D7915089FE4CC@shsmsx502.ccr.corp.intel.com> <20100618055929.GA11333@gondor.apana.org.au> <F2E9EB7348B8264F86B6AB8151CE2D7915089FE573@shsmsx502.ccr.corp.intel.com> <20100620100631.GB4578@redhat.com> <20100620103235.GA31284@gondor.apana.org.au> <20100620103909.GA5285@redhat.com> <20100620110254.GA31484@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Xin, Xiaohui" <xiaohui.xin@intel.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mingo@elte.hu" <mingo@elte.hu>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"jdike@linux.intel.com" <jdike@linux.intel.com>,
	Rusty Russell <rusty@rustcorp.com.au>
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100620110254.GA31484@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jun 20, 2010 at 09:02:54PM +1000, Herbert Xu wrote:
> On Sun, Jun 20, 2010 at 01:39:09PM +0300, Michael S. Tsirkin wrote:
> >
> > > It's just like migrating from a backend that supports TSO
> > > to one that doesn't.
> > 
> > Exactly. We don't support such migration.
> 
> Well that's something that has to be addressed in the virtio_net.

Rather than modifying all guests, it seems much easier not to assume
specific buffer layout in host.  Copying network header around seems a
small cost.

> Cheers,
> -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
