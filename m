From: Sean Hefty <mshefty@ichips.intel.com>
Subject: Re: [ofa-general] Re: [PATCH RFC] RDMA/CMA: Allocate PS_TCP ports
 from the host TCP port space.
Date: Thu, 09 Aug 2007 16:22:46 -0700
Message-ID: <46BBA1C6.9010702@ichips.intel.com>
References: <46B883B5.8040702@opengridcomputing.com>	<46BB61D0.4090101@opengridcomputing.com>	<46BB89C0.4040303@ichips.intel.com> <20070809.145534.102938208.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: swise@opengridcomputing.com, rdreier@cisco.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:27744 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752799AbXHIXWt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2007 19:22:49 -0400
In-Reply-To: <20070809.145534.102938208.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> How about we just remove the RDMA stack altogether?  I am not at all
> kidding.  If you guys can't stay in your sand box and need to cause
> problems for the normal network stack, it's unacceptable.  We were
> told all along the if RDMA went into the tree none of this kind of
> stuff would be an issue.

There are currently two RDMA solutions available.  Each solution has 
different requirements and uses the normal network stack differently. 
Infiniband uses its own transport.  iWarp runs over TCP.

We have tried to leverage the existing infrastructure where it makes sense.

> After TCP port reservation, what's next?  It seems an at least
> bi-monthly event that the RDMA folks need to put their fingers
> into something else in the normal networking stack.  No more.

Currently, the RDMA stack uses its own port space.  This causes a 
problem for iWarp, and is what Steve is looking for a solution for.  I'm 
not an iWarp guru, so I don't know what options exist.  Can iWarp use 
its own address family?  Identify specific IP addresses for iWarp use? 
Restrict iWarp to specific port numbers?  Let the app control the 
correct operation?  I don't know.

Steve merely defined a problem and suggested a possible solution.  He's 
looking for constructive help trying to solve the problem.

- Sean
