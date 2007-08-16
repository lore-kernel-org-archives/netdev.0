From: "Sean Hefty" <sean.hefty@intel.com>
Subject: RE: [ofa-general] Re: [PATCH RFC] RDMA/CMA: Allocate PS_TCP portsfrom
	the host TCP port space.
Date: Wed, 15 Aug 2007 20:27:26 -0700
Message-ID: <000001c7dfb5$5e6ced20$4dc8180a@amr.corp.intel.com>
References: <46B883B5.8040702@opengridcomputing.com>	<46BB61D0.4090101@opengridcomputing.com>	<46BB89C0.4040303@ichips.intel.com><20070809.145534.102938208.davem@davemloft.net><46C310E1.7020503@opengridcomputing.com>
	<46C3B5EF.5060409@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org, David Miller <davem@davemloft.net>
To: "'Jeff Garzik'" <jeff@garzik.org>,
	"Steve Wise" <swise@opengridcomputing.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <46C3B5EF.5060409@garzik.org>
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

>It's not about being a niche.  It's about creating a maintainable
>software net stack that has predictable behavior.
>
>Needing to reach out of the RDMA sandbox and reserve net stack resources
>away from itself travels a path we've consistently avoided.

We need to ensure that we're also creating a maintainable kernel.  RDMA doesn't
use sockets, but that doesn't mean it's not part of the networking support
provided by the Linux kernel.  Making blanket statements that RDMA should stay
within a sandbox is equivalent to saying that RDMA should duplicate any network
related functionality that it might need.

>>> I will NACK any patch that opens up sockets to eat up ports or
>>> anything stupid like that.
>
>Ditto for me as well.

I agree that using a socket is the wrong approach, but my guess is that it was
suggested as a possibility because of the attempt to keep RDMA in its 'sandbox'.
The iWarp architecture implements RDMA over TCP; it just doesn't use sockets.
The Linux network stack doesn't easily support this possibility.  Are there any
reasonable ways to enable this to the degree necessary for iWarp?

- Sean
