From: Paul Mackerras <paulus@samba.org>
Subject: Re: [PATCH] remove bogus exports in ppp
Date: Fri, 28 Jan 2005 11:00:02 +1100
Message-ID: <16889.32898.640799.219272@cargo.ozlabs.ibm.com>
References: <16889.31219.724098.168789@cargo.ozlabs.ibm.com>
	<20050127154246.3e4c26e6.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, hch@lst.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050127154246.3e4c26e6.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller writes:

> How likely is it that anything in the world makes any
> reference to this thing outside of the kernel tree?

Extremely unlikely.  The structures that they refer to are defined in
ppp_generic.c, not a header file, and aren't part of the generic PPP
API.  They should never have been exported in fact.

Paul.
