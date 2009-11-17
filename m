From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [net-next-2.6 PATCH 1/2] ethtool: Add PHY type to ethtool
 get_drvinfo
Date: Tue, 17 Nov 2009 09:07:19 -0800
Message-ID: <20091117090719.7d83492a@nehalam>
References: <20091117161309.11341.9165.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36219 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755660AbZKQRHT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Nov 2009 12:07:19 -0500
In-Reply-To: <20091117161309.11341.9165.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 17 Nov 2009 08:13:24 -0800
Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:

> From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> 
> Allow the PHY type to be passed from a driver to ethtool when
> ethtool -i ethX is called.  With newer network cards having SFP
> and SFP+ PHY cages, this information can be useful, especially
> if the NIC supports hot-swapping of the PHY modules.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---

Maybe revive usage of connector port in ethtool rather than adding new API?
It is already there but values are out of date with current hardware.
