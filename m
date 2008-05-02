From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/3] ixgbe: Add Data Center Bridging netlink listener
 for DCB runtime changes.
Date: Fri, 02 May 2008 07:03:29 -0400
Message-ID: <481AF501.3030507@pobox.com>
References: <20080502004254.14392.7599.stgit@localhost.localdomain> <20080502004300.14392.87943.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59405 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761715AbYEBLDd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 May 2008 07:03:33 -0400
In-Reply-To: <20080502004300.14392.87943.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PJ Waskiewicz wrote:
> This patch introduces a new generic netlink subsystem for Data Center
> Bridging, aka DCB.  The interface will allow userspace applications to
> configure the DCB parameters in the driver required to make the technology
> work.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/ixgbe/ixgbe_dcb_nl.c | 1273 ++++++++++++++++++++++++++++++++++++++
>  1 files changed, 1273 insertions(+), 0 deletions(-)

Seems to me we don't want each driver supporting this technology to 
create their own netlink interface...

This seems more appropriate via ethtool, or ethtool-netlink (Thomas Graf 
posted an RFC)

	Jeff




