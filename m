From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 1/1] e1000e: stop cleaning when we reach
 tx_ring->next_to_use
Date: Thu, 01 Apr 2010 21:13:18 -0700
Message-ID: <1270181598.14388.26.camel@localhost.localdomain>
References: <4BB3AA30.3060906@hp.com>
	 <20100401.193355.255461107.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "terry.loftin@hp.com" <terry.loftin@hp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:59337 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751279Ab0DBENU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Apr 2010 00:13:20 -0400
In-Reply-To: <20100401.193355.255461107.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-04-01 at 19:33 -0700, David Miller wrote:
> From: Terry Loftin <terry.loftin@hp.com>
> Date: Wed, 31 Mar 2010 14:01:52 -0600
> 
> > Tx ring buffers after tx_ring->next_to_use are volatile and could
> > change, possibly causing a crash.  Stop cleaning when we hit
> > tx_ring->next_to_use.
> > 
> > Signed-off-by: Terry Loftin <terry.loftin@hp.com>
> 
> Intel folks please look carefully at this fix.  I want to
> get it into net-2.6 if it's correct.
> 
> Thanks.

Got this one as well...

-- 
Cheers,
Jeff

