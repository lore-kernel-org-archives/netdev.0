From: James Morris <jmorris@redhat.com>
Subject: Re: [RFC] Replace scatterlist with crypto_frag
Date: Sat, 4 Jun 2005 01:23:55 -0400 (EDT)
Message-ID: <Xine.LNX.4.44.0506040122210.11356-100000@thoron.boston.redhat.com>
References: <20050604045119.GA25270@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Garzik <jgarzik@pobox.com>, "David S. Miller" <davem@davemloft.net>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050604045119.GA25270@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 4 Jun 2005, Herbert Xu wrote:

> Thanks James.  What do you think about eating up 32 bytes on the
> stack in esp_input/esp_output?

Sounds like a low price to pay, given the general overhead of ipsec.

> In fact, how did we come up with the number of four frags? Why wouldn't
> say two frags do for most users or perhaps even one?

I don't know where that came from.


- James
-- 
James Morris
<jmorris@redhat.com>
