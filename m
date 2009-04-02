From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Fri, 3 Apr 2009 01:17:27 +0800
Message-ID: <20090402171727.GA3127@gondor.apana.org.au>
References: <200904022243.21088.rusty@rustcorp.com.au> <49D4B4A3.5070008@novell.com> <49D4B87D.2000202@redhat.com> <20090402145018.GA816@gondor.apana.org.au> <49D4D301.2090209@redhat.com> <20090402154041.GA1774@gondor.apana.org.au> <49D4E072.2060003@redhat.com> <20090402160941.GB2173@gondor.apana.org.au> <49D4EDBD.3050900@redhat.com> <20090402170610.GA3001@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gregory Haskins <ghaskins@novell.com>,
	Rusty Russell <rusty@rustcorp.com.au>, anthony@codemonkey.ws,
	andi@firstfloor.org, linux-kernel@vger.kernel.org, agraf@suse.de,
	pmullaney@novell.com, pmorreale@novell.com, netdev@vger.kernel.org,
	kvm@vger.kernel.org, Ingo Molnar <mingo@elte.hu>
To: Avi Kivity <avi@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090402170610.GA3001@gondor.apana.org.au>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 03, 2009 at 01:06:10AM +0800, Herbert Xu wrote:
>
> That only happens if the guest immediately does some CPU-intensive
> computation 3ms and assuming its timeslice lasts that long.
> 
> In any case, the same thing will happen right now if the host or
> some other guest on the same CPU hogs the CPU for 3ms.

Even better, look at the packet's TOS.  If it's marked for low-
latency then vmexit immediately.  Otherwise continue.

In the backend you'd just set the marker in shared memory.

Of course invert this for the host => guest direction.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
