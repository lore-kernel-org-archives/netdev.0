From: David Miller <davem@davemloft.net>
Subject: Re: [ofa-general] Re: [PATCH RFC] RDMA/CMA: Allocate PS_TCP ports
	from the host TCP port space.
Date: Thu, 09 Aug 2007 14:55:34 -0700 (PDT)
Message-ID: <20070809.145534.102938208.davem@davemloft.net>
References: <46B883B5.8040702@opengridcomputing.com>
	<46BB61D0.4090101@opengridcomputing.com>
	<46BB89C0.4040303@ichips.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org
To: mshefty@ichips.intel.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <46BB89C0.4040303@ichips.intel.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

From: Sean Hefty <mshefty@ichips.intel.com>
Date: Thu, 09 Aug 2007 14:40:16 -0700

> Steve Wise wrote:
> > Any more comments?
> 
> Does anyone have ideas on how to reserve the port space without using a 
> struct socket?

How about we just remove the RDMA stack altogether?  I am not at all
kidding.  If you guys can't stay in your sand box and need to cause
problems for the normal network stack, it's unacceptable.  We were
told all along the if RDMA went into the tree none of this kind of
stuff would be an issue.

These are exactly the kinds of problems for which people like myself
were dreading.  These subsystems have no buisness using the TCP port
space of the Linux software stack, absolutely none.

After TCP port reservation, what's next?  It seems an at least
bi-monthly event that the RDMA folks need to put their fingers
into something else in the normal networking stack.  No more.

I will NACK any patch that opens up sockets to eat up ports or
anything stupid like that.
