From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [ofa-general] Re: [PATCH RFC] RDMA/CMA: Allocate PS_TCP ports
	from the host TCP port space.
Date: Thu, 16 Aug 2007 08:43:11 -0500
Message-ID: <1187271791.4685.9.camel@trinity.ogc.int>
References: <46B883B5.8040702@opengridcomputing.com>
	<46BB61D0.4090101@opengridcomputing.com>
	<46BB89C0.4040303@ichips.intel.com>
	<20070809.145534.102938208.davem@davemloft.net>
	<46C310E1.7020503@opengridcomputing.com> <46C3B5EF.5060409@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org, David Miller <davem@davemloft.net>
To: Jeff Garzik <jeff@garzik.org>
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

On Wed, 2007-08-15 at 22:26 -0400, Jeff Garzik wrote:

[...snip...]

> > I think removing the RDMA stack is the wrong thing to do, and you 
> > shouldn't just threaten to yank entire subsystems because you don't like 
> > the technology.  Lets keep this constructive, can we?  RDMA should get 
> > the respect of any other technology in Linux.  Maybe its a niche in your 
> > opinion, but come on, there's more RDMA users than say, the sparc64 
> > port.  Eh?
> 
> It's not about being a niche.  It's about creating a maintainable 
> software net stack that has predictable behavior.

Isn't RDMA _part_ of the "software net stack" within Linux? Why isn't
making RDMA stable, supportable and maintainable equally as important as
any other subsystem? 

> 
> Needing to reach out of the RDMA sandbox and reserve net stack resources 
> away from itself travels a path we've consistently avoided.
> 
> 
> >> I will NACK any patch that opens up sockets to eat up ports or
> >> anything stupid like that.
> > 
> > Got it.
> 
> Ditto for me as well.
> 
> 	Jeff
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
