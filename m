From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: sha512: make it work, undo percpu message schedule
Date: Fri, 13 Jan 2012 17:50:41 +1100
Message-ID: <20120113065040.GA18680@gondor.apana.org.au>
References: <20120111000040.GA3801@p183.telecom.by> <20120111003611.GA12257@gondor.apana.org.au> <20120113062256.GC12501@secunet.com> <1326437318.2617.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	ken@codelabs.ch
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1326437318.2617.17.camel@edumazet-laptop>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 13, 2012 at 07:48:38AM +0100, Eric Dumazet wrote:
>
> Another solution is using two blocks, one used from interrupt context.
> 
> static DEFINE_PER_CPU(u64[80], msg_schedule);
> static DEFINE_PER_CPU(u64[80], msg_schedule_irq);
> 
> (Like we do for SNMP mibs on !x86 arches)

Yes that sounds good.  Thanks Eric!
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
