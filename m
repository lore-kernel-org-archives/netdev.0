From: "David S. Miller" <davem@redhat.com>
Subject: Re: [IPSEC] Drop bogus NAT-T printks in esp_input
Date: Sat, 26 Jun 2004 11:36:03 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040626113603.2c928d1d.davem@redhat.com>
References: <20040625121147.GA11231@gondor.apana.org.au>
	<20040625123527.GA11685@gondor.apana.org.au>
	<20040625103928.3b1b3275.davem@redhat.com>
	<20040626015715.GA16496@gondor.apana.org.au>
	<20040626100718.GA28367@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040626100718.GA28367@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 26 Jun 2004 20:07:18 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Sat, Jun 26, 2004 at 11:57:15AM +1000, herbert wrote:
> > 
> > However, printing a warning and then continuing is definitely wrong.
> > So expect a follow-up patch to drop the packet when encap_type is
> > unknown in esp_input.
> 
> Here is the patch to drop the packet if encap_type is unknown.
> I've also removed the other two bogus printk's as they cannot
> occur (printing a message is the last thing you want to do even
> if they did occur :).

Also applied, thanks.
