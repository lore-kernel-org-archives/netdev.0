From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] e1000e: balance semaphore put/get for 82573
Date: Tue, 27 Aug 2013 16:05:56 -0400 (EDT)
Message-ID: <20130827.160556.2200367613255828407.davem@davemloft.net>
References: <1377303577-12180-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sla@riverbed.com, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59454 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752288Ab3H0UF6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 16:05:58 -0400
In-Reply-To: <1377303577-12180-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 23 Aug 2013 17:19:37 -0700

> From: Steven La <sla@riverbed.com>
> 
> Steven (cc-ed) noticed an imbalance in semaphore put/get for
> 82573-based NICs. Don't we need something like the following
> (untested) patch?
> 
> Signed-off-by: Steven La <sla@riverbed.com>
> Acked-by: Arthur Kepner <akepner@riverbed.com>
> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
