From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Tue, 17 May 2005 17:51:26 -0700 (PDT)
Message-ID: <20050517.175126.74751342.davem@davemloft.net>
References: <20050517232556.GA26846@gondor.apana.org.au>
	<428A871F.1000308@us.ibm.com>
	<20050518001054.GB27212@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: niv@us.ibm.com, akepner@sgi.com, dlstevens@us.ibm.com, rick.jones2@hp.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au
In-Reply-To: <20050518001054.GB27212@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Wed, 18 May 2005 10:10:54 +1000

> On Tue, May 17, 2005 at 05:06:55PM -0700, Nivedita Singhvi wrote:
> > 
> > Mainline linux certainly has this (per-inetpeer ip_id) - but
> > at least one distro did not (use inetpeer) :). Not sure
> > what the current situation is.
> 
> What was the reason for this? Perhaps we can solve their problems
> with inetpeer in a better way than disabling it?

Andi Kleen thought inetpeer was a pig, so he removed it from SUSE's
kernel and replaced it with a per-cpu salted IP ID generator.  The
initial verion he wrote had serious bugs that severely decreased the
effective ID space, and thus made the NFS corruption problem happen
more frequently.
