From: Christoph Lameter <christoph@lameter.com>
Subject: Re: atomic_dec_and_test for child dst needed in dst_destroy?
Date: Wed, 6 Apr 2005 11:48:50 -0700 (PDT)
Message-ID: <Pine.LNX.4.58.0504061146060.7083@graphe.net>
References: <Pine.LNX.4.58.0504051925250.21486@graphe.net>
 <E1DJ5y2-0003rF-00@gondolin.me.apana.org.au> <20050406111721.3ac67605.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050406111721.3ac67605.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 6 Apr 2005, David S. Miller wrote:

> See his other emails in this thread.  If it can be converted to
> atomic_dec() then he wants to change the counter into an array
> of counters on NUMA systems.

Correct.

> But his trick only works if the atomic_dec_and_test() can be eliminated
> for all cases, which we're now quite certain is not possible.

Some changes to the way locking is done between the garbage collector
and dst_destroy would be necessary. Lets see if the author
of the patch can come up with a solution to this.
