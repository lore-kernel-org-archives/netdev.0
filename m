From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [PATCH 2/2] ixgbe: fix select_queue management
Date: Fri, 20 Mar 2009 00:23:39 -0700 (Pacific Daylight Time)
Message-ID: <Pine.WNT.4.64.0903200019240.14460@ppwaskie-MOBL2.amr.corp.intel.com>
References: <20090319233404.6697768b@nehalam> <20090319233610.51fe4ee1@nehalam>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:50168 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750782AbZCTHXn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Mar 2009 03:23:43 -0400
In-Reply-To: <20090319233610.51fe4ee1@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 19 Mar 2009, Stephen Hemminger wrote:

> Convert ixgbe to use net_device_ops properly.
> Rather than changing the select_queue function pointer
> just check the flag.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Thanks Stephen.  I was looking at reassigning a DCB netdev_ops struct when 
DCB is enabled, and then having a default netdev_ops struct when it's not 
enabled.  I agree the check is cleaner the way you have it below, but it's 
another conditional check in the Tx hotpath, which we have too many of in 
the first place.

On a related side note, why is the netdev_ops member of net_device 
declared const?

Cheers,
-PJ Waskiewicz
