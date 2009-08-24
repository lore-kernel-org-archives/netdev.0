From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] RDS: TCP transport support
Date: Sun, 23 Aug 2009 19:13:42 -0700 (PDT)
Message-ID: <20090823.191342.86319826.davem@davemloft.net>
References: <1250893715-21939-1-git-send-email-andy.grover@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rds-devel@oss.oracle.com
To: andy.grover@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51737
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751083AbZHXCN3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Aug 2009 22:13:29 -0400
In-Reply-To: <1250893715-21939-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Grover <andy.grover@oracle.com>
Date: Fri, 21 Aug 2009 15:28:30 -0700

> This patch series adds a TCP transport for RDS. Instead of requiring
> an IB queue pair for communication between two nodes, it may instead 
> tunnel traffic over a TCP connection. This makes RDS usable by
> people without IB hardware, or in a VM.
> 
> In addition, this patchset modularizes RDS into an rds core module,
> an rds_rdma module (for Infiniband and iWARP) and rds_tcp module. RDS
> itself no longer has a dependency on IB (the rds_rdma module does).
> 
> This code has been tested and verified to work and perform acceptably, 
> but has not yet had intensive performance analysis.

All applied to net-next-2.6, thanks.

I'll push it out to kernel.org after some build tests.
