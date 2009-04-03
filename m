From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Fri, 3 Apr 2009 19:12:42 +0800
Message-ID: <20090403111242.GA10200@gondor.apana.org.au>
References: <20090402085253.GA29932@gondor.apana.org.au> <49D47F11.6070400@redhat.com> <49D5EBE1.8030200@redhat.com> <49D5ED11.2000800@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gerd Hoffmann <kraxel@redhat.com>, ghaskins@novell.com,
	anthony@codemonkey.ws, andi@firstfloor.org,
	linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Avi Kivity <avi@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <49D5ED11.2000800@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 03, 2009 at 02:03:45PM +0300, Avi Kivity wrote:
>
> If the host is able to consume a request immediately, and the guest is  
> not able to batch requests, this breaks down.  And that is the current  
> situation.

Hang on, why is the host consuming the request immediately? It
has to write the packet to tap, which then calls netif_rx_ni so
it should actually go all the way, no?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
