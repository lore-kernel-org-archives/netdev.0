From: "David S. Miller" <davem@davemloft.net>
Subject: Re: neigh_create/inetdev_destroy race?
Date: Fri, 3 Sep 2004 09:18:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040903091817.7b97d090.davem@davemloft.net>
References: <20040814050848.GA11874@gondor.apana.org.au>
	<20040814062703.GA4806@gondor.apana.org.au>
	<20040815191450.77532d5d.davem@redhat.com>
	<20040816105131.GA11299@gondor.apana.org.au>
	<20040828234201.79556f6e.davem@davemloft.net>
	<20040829065031.GA786@gondor.apana.org.au>
	<20040830230820.7514985d.davem@davemloft.net>
	<20040831104139.GA2124@gondor.apana.org.au>
	<20040901222118.0ce4bcc6.davem@davemloft.net>
	<20040902130605.GA32570@gondor.apana.org.au>
	<20040903133623.GA23179@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040903133623.GA23179@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 3 Sep 2004 23:36:23 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Here is the patch.

Looks great.  Yes, I see how the existing cases were racey
pre-RCU, it is similar to the sysctl stuff and that area was
truly horrible before Stephen and myself redid how generic
device destruction works.

Patch applied, thanks Herbert.
