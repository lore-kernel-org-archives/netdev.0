From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v2 1/2] net: Add layer 2 hardware acceleration operations
 for macvlan devices
Date: Tue, 5 Nov 2013 09:15:38 -0500
Message-ID: <20131105141538.GA14954@hmsreliant.think-freely.org>
References: <20131104185717.11802.69282.stgit@jf-dev1-dcblab>
 <20131104190149.11802.34110.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org,
	andy@greyhouse.net, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:57513 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755142Ab3KEOPt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Nov 2013 09:15:49 -0500
Content-Disposition: inline
In-Reply-To: <20131104190149.11802.34110.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 04, 2013 at 11:01:49AM -0800, John Fastabend wrote:
> Add a operations structure that allows a network interface to export
> the fact that it supports package forwarding in hardware between
> physical interfaces and other mac layer devices assigned to it (such
> as macvlans). This operaions structure can be used by virtual mac
> devices to bypass software switching so that forwarding can be done
> in hardware more efficiently.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> CC: "David S. Miller" <davem@davemloft.net>
For when you send your V3 patch set out:
Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
