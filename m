From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [net-next PATCH v3 2/2] ixgbe: enable l2 forwarding acceleration
 for macvlans
Date: Wed, 6 Nov 2013 08:59:20 -0500
Message-ID: <20131106135920.GA6357@neilslaptop.think-freely.org>
References: <20131105232443.5400.97238.stgit@jf-dev1-dcblab>
 <20131105233017.5400.91554.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexander.h.duyck@intel.com, andy@greyhouse.net,
	davem@davemloft.net, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, vyasevich@gmail.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:43062 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756185Ab3KFN7o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 08:59:44 -0500
Content-Disposition: inline
In-Reply-To: <20131105233017.5400.91554.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 05, 2013 at 03:30:17PM -0800, John Fastabend wrote:
> Now that l2 acceleration ops are in place from the prior patch,
> enable ixgbe to take advantage of these operations.  Allow it to
> allocate queues for a macvlan so that when we transmit a frame,
> we can do the switching in hardware inside the ixgbe card, rather
> than in software.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> CC: "David S. Miller" <davem@davemloft.net>
> ---
Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
