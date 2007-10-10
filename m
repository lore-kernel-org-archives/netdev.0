From: Sean Hefty <mshefty@ichips.intel.com>
Subject: Re: [ofa-general] Re: [PATCH RFC] RDMA/CMA: Allocate PS_TCP ports
	from the host TCP port space.
Date: Wed, 10 Oct 2007 14:01:07 -0700
Message-ID: <470D3D93.2020606@ichips.intel.com>
References: <46B883B5.8040702@opengridcomputing.com>	<46BB61D0.4090101@opengridcomputing.com>	<46BB89C0.4040303@ichips.intel.com>
	<20070809.145534.102938208.davem@davemloft.net>
	<470AA729.2050009@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com,
	David Miller <davem@davemloft.net>,
	general@lists.openfabrics.org, linux-kernel@vger.kernel.org
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <470AA729.2050009@opengridcomputing.com>
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

> The hack to use a socket and bind it to claim the port was just for 
> demostrating the idea.  The correct solution, IMO, is to enhance the 
> core low level 4-tuple allocation services to be more generic (eg: not 
> be tied to a struct sock).  Then the host tcp stack and the host rdma 
> stack can allocate TCP/iWARP ports/4tuples from this common exported 
> service and share the port space.  This allocation service could also be 
> used by other deep adapters like iscsi adapters if needed.

Since iWarp runs on top of TCP, the port space is really the same. 
FWIW, I agree that this proposal is the correct solution to support iWarp.

- Sean
