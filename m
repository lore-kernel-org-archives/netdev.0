From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/2] virtio_net: remove send completion interrupts and
	avoid TX queue overrun through packet drop
Date: Fri, 18 Mar 2011 08:33:11 -0500
Message-ID: <20110318133311.GA20623@gondor.apana.org.au>
References: <1300320775.3255.34.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mst@redhat.com, rusty@rustcorp.com.au, davem@davemloft.net,
	kvm@vger.kernel.org, netdev@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1300320775.3255.34.camel@localhost.localdomain>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Shirley Ma <mashirle@us.ibm.com> wrote:
>
> +       /* Drop packet instead of stop queue for better performance */

I would like to see some justification as to why this is the right
way to go and not just papering over the real problem.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
