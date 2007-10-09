From: James Lentini <jlentini@netapp.com>
Subject: Re: [ofa-general] Re: [PATCH RFC] RDMA/CMA: Allocate PS_TCP ports
 from the host TCP port space.
Date: Tue, 9 Oct 2007 09:44:02 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0710090934340.32008@jlentini-linux.nane.netapp.com>
References: <46B883B5.8040702@opengridcomputing.com> <46BB61D0.4090101@opengridcomputing.com>
 <46BB89C0.4040303@ichips.intel.com> <20070809.145534.102938208.davem@davemloft.net>
 <470AA729.2050009@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, rdreier@cisco.com,
	linux-kernel@vger.kernel.org, general@lists.openfabrics.org,
	netdev@vger.kernel.org
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14030 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750993AbXJINoV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Oct 2007 09:44:21 -0400
In-Reply-To: <470AA729.2050009@opengridcomputing.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Mon, 8 Oct 2007, Steve Wise wrote:

> The correct solution, IMO, is to enhance the core low level 4-tuple 
> allocation services to be more generic (eg: not be tied to a struct 
> sock).  Then the host tcp stack and the host rdma stack can allocate 
> TCP/iWARP ports/4tuples from this common exported service and share 
> the port space.  This allocation service could also be used by other 
> deep adapters like iscsi adapters if needed.

As a developer of an RDMA ULP, NFS-RDMA, I like this approach because 
it will simplify the configuration of an RDMA device and the services 
that use it.
