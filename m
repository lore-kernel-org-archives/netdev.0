From: "David S. Miller" <davem@redhat.com>
Subject: Re: [INET] Create enum of ECN bits
Date: Thu, 22 Jul 2004 12:22:38 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040722122238.6759b75b.davem@redhat.com>
References: <20040722120021.GA18293@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040722120021.GA18293@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 22 Jul 2004 22:00:21 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> This patch is a preparation for an update of the ECN encap/decap
> code with respect to RFC3168.
> 
> It creates an enum of the four code-points defined by RFC3168
> and uses them throughout the inet_ecn.h file.
> 
> The only non-trivial bit is in IP_ECN_set_ce/IP6_ECN_set_ce where
> the patch uses INET_ECN_CE instead of 1.  This is OK as those
> functions assume that the ECT bit is already set.

Looks great, applied.
