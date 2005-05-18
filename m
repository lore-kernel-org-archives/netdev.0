From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Wed, 18 May 2005 11:13:08 +1000
Message-ID: <20050518011308.GA27780@gondor.apana.org.au>
References: <20050517232556.GA26846@gondor.apana.org.au> <428A871F.1000308@us.ibm.com> <20050518001054.GB27212@gondor.apana.org.au> <20050517.175126.74751342.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: niv@us.ibm.com, akepner@sgi.com, dlstevens@us.ibm.com, rick.jones2@hp.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050517.175126.74751342.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, May 17, 2005 at 05:51:26PM -0700, David S. Miller wrote:
> 
> Andi Kleen thought inetpeer was a pig, so he removed it from SUSE's
> kernel and replaced it with a per-cpu salted IP ID generator.  The
> initial verion he wrote had serious bugs that severely decreased the
> effective ID space, and thus made the NFS corruption problem happen
> more frequently.

Is he turning off PMTU by default as well? :) I don't see how it
can be a pig otherwise.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
