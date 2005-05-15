From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPV4/IPV6] Ensure all frag_list members have NULL sk
Date: Mon, 16 May 2005 07:29:42 +1000
Message-ID: <20050515212942.GA19296@gondor.apana.org.au>
References: <20050514134834.GA2698@uganda.factory.vocord.ru> <E1DXE3h-0002jR-00@gondolin.me.apana.org.au> <20050515104016.GA24344@gondor.apana.org.au> <20050515114121.GA4830@gondor.apana.org.au> <20050515122256.GA22251@gondor.apana.org.au> <20050515213341.4011c00e@zanzibar.2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Content-Disposition: inline
In-Reply-To: <20050515213341.4011c00e@zanzibar.2ka.mipt.ru>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, May 15, 2005 at 09:33:41PM +0400, Evgeniy Polyakov wrote:
>
> > So let's go the other way and make this an invariant:
> > 
> > 	For any skb on a frag_list, skb->sk must be NULL.
> 
> This requires skb_set_owner_* to check if it is called
> for head skb or one from fragment and does nothing if
> it is from frag_list.
> Or to check the whole tree for ownering calls...

Not really.  The frag_list skb's owned by sk's are generated in
one place only, and that place is ip*_push_pending_frames.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
