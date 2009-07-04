From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 3/4] ixgbe: fix inconsistent SFP/SFP+ failure
 results.
Date: Fri, 03 Jul 2009 19:12:19 -0700 (PDT)
Message-ID: <20090703.191219.159352502.davem@davemloft.net>
References: <20090702225012.22746.57218.stgit@localhost.localdomain>
	<20090702225051.22746.79159.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	donald.c.skidmore@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36295
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757706AbZGDCMN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2009 22:12:13 -0400
In-Reply-To: <20090702225051.22746.79159.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 02 Jul 2009 15:50:52 -0700

> From: Don Skidmore <donald.c.skidmore@intel.com>
> 
> Currently if we loaded the driver, insert an unsupported module, and then
> attempt to "ifconfig up" the device it will be brought down but the netdev
> would not be unregistered. This behavior is different than all other
> code paths. This patch corrects that by down'ing the device and then
> scheduling the sfp_config_module_task tasklet. The tasklet will detect
> this condition (like it does with other code paths) and do the
> unregister_netdev().
> 
> I also removed the log message as this condition (an unsupported SFP+
> module) will be logged in sfp_config_module_task.
> 
> Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
