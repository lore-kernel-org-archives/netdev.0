From: "David S. Miller" <davem@redhat.com>
Subject: Re: [IPSEC] Remove run-time encap_type checks in esp4
Date: Sat, 26 Jun 2004 11:35:24 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040626113524.18a20d0f.davem@redhat.com>
References: <20040625121147.GA11231@gondor.apana.org.au>
	<20040625123527.GA11685@gondor.apana.org.au>
	<20040625103928.3b1b3275.davem@redhat.com>
	<20040626015715.GA16496@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040626015715.GA16496@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 26 Jun 2004 11:57:15 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> This allows us to remove all the per-packet checks on x->encap->encap_type.
> I've left the check in esp_input just in case someone adds a non-ESP encap
> type in future.

Applied.
