From: David Miller <davem@davemloft.net>
Subject: Re: [net 2/2] ixgbe: add warning when max_vfs is out of range.
Date: Mon, 11 Nov 2013 00:46:50 -0500 (EST)
Message-ID: <20131111.004650.524780969167147670.davem@davemloft.net>
References: <1384001552-18754-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jacob.e.keller@intel.com, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52431 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751894Ab3KKFqv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 00:46:51 -0500
In-Reply-To: <1384001552-18754-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat,  9 Nov 2013 04:52:32 -0800

> From: Jacob Keller <jacob.e.keller@intel.com>
> 
> The max_vfs parameter has a limit of 63 and silently fails (adding 0 vfs) when
> it is out of range. This patch adds a warning so that the user knows something
> went wrong. Also, this patch moves the warning in ixgbe_enable_sriov() to where
> max_vfs is checked, so that even an out of range value will show the deprecated
> warning. Previously, an out of range parameter didn't even warn the user to use
> the new sysfs interface instead.
> 
> Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
> Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
