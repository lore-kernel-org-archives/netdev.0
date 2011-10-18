From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: PROBLEM: System call 'sendmsg' of process ospfd (quagga)
	causes kernel oops
Date: Tue, 18 Oct 2011 15:45:37 +0200
Message-ID: <20111018134537.GA17055@gondor.apana.org.au>
References: <CA+0Zf5A-8X5MaXC4+BbLKtMb8S8B-Ln_a3JNfz0jR4O-ruefuw@mail.gmail.com> <1318905032.2571.35.camel@edumazet-laptop> <20111018093411.GA15165@gondor.apana.org.au> <1318932093.2657.26.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <20111018100527.GA15383@gondor.apana.org.au> <1318933423.2657.44.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <20111018104504.GA15913@gondor.apana.org.au> <1318937878.2657.50.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <20111018114945.GA16359@gondor.apana.org.au> <1318942560.2657.69.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Elmar Vonlanthen <evonlanthen@gmail.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1318942560.2657.69.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 18, 2011 at 02:56:00PM +0200, Eric Dumazet wrote:
>
> I am ok by this way, but we might hit another similar problem elsewhere.
> 
> (igmp.c ip6_output, ...)
> 
> We effectively want to remove LL_ALLOCATED_SPACE() usage and obfuscate
> code...

Here's another idea, provide a helper to do the skb allocation
and the skb_reserve in one go.  That way this ugliness would only
need to be done once.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
