From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/8] rds: Pass pointers to virt_to_page(), not integers
Date: Mon, 28 Oct 2013 00:26:54 -0400 (EDT)
Message-ID: <20131028.002654.404759341390215962.davem@davemloft.net>
References: <1382910437.2994.43.camel@deadeye.wl.decadent.org.uk>
	<1382910856.2994.51.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: venkat.x.venkatsubra@oracle.com, linux-kernel@vger.kernel.org,
	rds-devel@oss.oracle.com, netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382910856.2994.51.camel@deadeye.wl.decadent.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <ben@decadent.org.uk>
Date: Sun, 27 Oct 2013 21:54:16 +0000

> Most architectures define virt_to_page() as a macro that casts its
> argument such that an argument of type unsigned long will be accepted
> without complaint.  However, the proper type is void *, and passing
> unsigned long results in a warning on MIPS.
> 
> Compile-tested only.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

This looks fine:

Acked-by: David S. Miller <davem@davemloft.net>
