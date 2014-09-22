From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] r8152: disable ALDPS
Date: Mon, 22 Sep 2014 14:54:46 -0400 (EDT)
Message-ID: <20140922.145446.2112922203236872469.davem@davemloft.net>
References: <1394712342-15778-44-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52925 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751730AbaIVSys (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 14:54:48 -0400
In-Reply-To: <1394712342-15778-44-Taiwan-albertk@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hayes Wang <hayeswang@realtek.com>
Date: Fri, 19 Sep 2014 15:17:18 +0800

> If the hw is in ALDPS mode, the hw may have no response for accessing
> the most registers. Therefore, the ALDPS should be disabled before
> accessing the hw in rtl_ops.init(), rtl_ops.disable(), rtl_ops.up(),
> and rtl_ops.down(). Regardless of rtl_ops.enable(), because the hw
> wouldn't enter ALDPS mode when linking on. The hw would enter the
> ALDPS mode after several seconds when link down occurs and the ALDPS
> is enabled.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Applied, thanks.
