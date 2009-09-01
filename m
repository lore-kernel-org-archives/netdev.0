From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: Does ESP support 64 bit sequence numbering for authentication
	hash ?
Date: Tue, 1 Sep 2009 14:09:15 +0200
Message-ID: <20090901120915.GA12646@secunet.com>
References: <1231943033.7937.120.camel@libdev3.mvista.co.uk> <20090115055644.GA30626@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: djenkins@mvista.com, linux-crypto@vger.kernel.org,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090115055644.GA30626@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 15, 2009 at 04:56:44PM +1100, Herbert Xu wrote:
> Dean Jenkins <djenkins@mvista.com> wrote:
> > 
> > Does ESP support 64 bit sequence numbering for use with the
> > authentication HMAC ?
> 
> We don't support 64-bit sequence numbers yet.  If you look at
> struct xfrm_replay_state which is where we store the sequence
> number internally you'll find that it uses u32s.
> 
> Patches for 64-bit support are welcome of course.
> 

Is there actually anybody working on 64-bit sequence number support?
If not, I'd start to look at it.
