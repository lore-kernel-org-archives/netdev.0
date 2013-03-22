From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH] net: Add support for handling queueing in hardware
Date: Fri, 22 Mar 2013 18:08:40 -0400
Message-ID: <20130322220840.GA6647@thunk.org>
References: <A5ACC15C-361D-48E6-BFFF-9AA3966C2A68@freescale.com>
 <20130322.103302.1277256650283142022.davem@davemloft.net>
 <FE78128C-01DB-4831-ACBE-BA3E3A428BFC@gmail.com>
 <20130322.111759.2108472348146991505.davem@davemloft.net>
 <9AEAD974-4549-475A-AE15-C92523CD2466@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, afleming@freescale.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Ben Collins <benmcollins13@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <9AEAD974-4549-475A-AE15-C92523CD2466@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 22, 2013 at 11:39:20AM -0400, Ben Collins wrote:
> 
> If your company had hardware going to production, you'd want it supported in mainline too, I suspect.

And if companies told their hardware partners that they will drop use
of their hardware in future products unless they get their !@#@S
drivers upstream, I'd bet they'd change their engineering priorities
so they would work on it, instead of foisting this work on their
customers.

I've seen this work in enterprise computing, where the RFP had
requirements for upstream drivers (i.e., if you want your 10gig
ethernet NIC to be used in HP or IBM's servers, get the darned thing
upstream!).  The trick is making it clear that selection of components
depends not just on an OSS driver, but an OSS driver which has been
accepted upstream (which also helps from a quality-of-code
requirement).

I've been waiting for this to start happening in the consumer
electronics/embedded world, but it's been slow coming,
unfortunately....

                                                   - Ted
