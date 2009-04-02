From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Thu, 2 Apr 2009 17:33:24 +0800
Message-ID: <20090402093324.GA30397@gondor.apana.org.au>
References: <20090402085253.GA29932@gondor.apana.org.au> <49D47F11.6070400@redhat.com> <20090402091639.GA30126@gondor.apana.org.au> <49D484F5.2000400@redhat.com> <20090402092936.GA30333@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ghaskins@novell.com, anthony@codemonkey.ws, andi@firstfloor.org,
	linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	Patrick Ohly <patrick.ohly@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: Avi Kivity <avi@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090402092936.GA30333@gondor.apana.org.au>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 02, 2009 at 05:29:36PM +0800, Herbert Xu wrote:
> On Thu, Apr 02, 2009 at 12:27:17PM +0300, Avi Kivity wrote:
> >
> > If tap told us when the packets were actually transmitted, life would be  
> > wonderful:
> 
> And why do we need this? Because we are in user space!
> 
> I'll continue to wait for your patch and numbers :)

And in case you're working on that patch, this might interest
you.  Check out the netdev thread titled "TX time stamping".
Now that we assign the tap skb with its own sk, these two scenarios
are pretty much identical.

I also noitced despite davem's threats to revert the patch, it
has now made Linus's tree :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
