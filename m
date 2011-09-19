From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 11/13] igb: Make Tx budget for NAPI user adjustable
Date: Mon, 19 Sep 2011 16:57:08 -0400 (EDT)
Message-ID: <20110919.165708.2092635575746194747.davem@davemloft.net>
References: <1316246677-8830-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1316246677-8830-12-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44815 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750874Ab1ISU5Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2011 16:57:16 -0400
In-Reply-To: <1316246677-8830-12-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat, 17 Sep 2011 01:04:35 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This change is meant to make the NAPI budget limits for transmit
> adjustable.  By doing this it is possible to tune the value for optimal
> performance with applications such as routing.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Tested-by:  Aaron Brown  <aaron.f.brown@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

As Ben and I have mentioned, this change is not acceptable.

Ethtool settings for "hardware interrupt" coalescing and mitigation
should have no effect on NAPI behavior.
