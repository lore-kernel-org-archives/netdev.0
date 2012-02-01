From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] ixgbe: Add module parameter to allow untested and
 unsafe SFP+ modules
Date: Wed, 01 Feb 2012 14:24:14 -0500 (EST)
Message-ID: <20120201.142414.698250338068347063.davem@davemloft.net>
References: <1328123961-17237-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, hawk@comx.dk
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33520 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751420Ab2BATYX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2012 14:24:23 -0500
In-Reply-To: <1328123961-17237-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed,  1 Feb 2012 11:19:21 -0800

> From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> 
> The X520 family of network devices, with the 82599 chip, support a
> small number of Intel-verified SFP+ modules on their NICs.  To maintain
> stability and quality, the current devices restrict untested 3rd party
> SFP+ modules.
> 
> This patch introduces a module parameter for ixgbe to allow these untested
> modules at the user's peril.  It also includes a warning to the syslog
> alerting users that the modules aren't supported, and results may
> vary.
> 
> CC: Jesper Dangaard Brouer <hawk@comx.dk>
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks.
