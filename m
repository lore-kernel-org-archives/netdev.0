From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Fri, 3 Apr 2009 19:34:50 +0800
Message-ID: <20090403113450.GA10352@gondor.apana.org.au>
References: <20090402085253.GA29932@gondor.apana.org.au> <49D47F11.6070400@redhat.com> <49D5EBE1.8030200@redhat.com> <20090403111854.GA11935@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gerd Hoffmann <kraxel@redhat.com>, Avi Kivity <avi@redhat.com>,
	ghaskins@novell.com, anthony@codemonkey.ws,
	linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1764762AbZDCLfc@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090403111854.GA11935@one.firstfloor.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 03, 2009 at 01:18:54PM +0200, Andi Kleen wrote:
> > Check shared ring status when stuffing a request.  If there are requests
> 
> That means you're bouncing cache lines all the time. Probably not a big
> issue on single socket but could be on larger systems.

If the backend is running on a core that doesn't share caches
with the guest queue then you've got bigger problems.

Right this is unavoidable for guests with many CPUs but that
should go away once we support multiqueue in virtio-net.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
