From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [IPSEC] Implement DSCP decapsulation
Date: Thu, 16 Sep 2004 13:28:22 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040916132822.0f1ae663.davem@davemloft.net>
References: <20040916123939.GA3403@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, jmorris@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040916123939.GA3403@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 16 Sep 2004 22:39:39 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> This patch adds DSCP decapsulation for IPsec.  This is enabled by
> a per-state flag which is off by default.  Leaving it off by default
> maintains compatibility and is also good for performance reasons.
> 
> I decided to not implement a toggle on the output path since not
> encapsulating the DSCP can and should be done by netfilter.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Looks great.  Patch applied, thanks Herbert.
