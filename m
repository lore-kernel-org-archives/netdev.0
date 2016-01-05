From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] r8152: add reset_resume function
Date: Mon, 04 Jan 2016 22:02:37 -0500 (EST)
Message-ID: <20160104.220237.1179574448077753537.davem@davemloft.net>
References: <1394712342-15778-169-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50851 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754030AbcAEDCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 22:02:39 -0500
In-Reply-To: <1394712342-15778-169-Taiwan-albertk@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hayes Wang <hayeswang@realtek.com>
Date: Mon, 4 Jan 2016 14:38:46 +0800

> When the reset_resume() is called, the flag of SELECTIVE_SUSPEND should be
> cleared and reinitialize the device, whether the SELECTIVE_SUSPEND is set
> or not. If reset_resume() is called, it means the power supply is cut or the
> device is reset. That is, the device wouldn't be in runtime suspend state and
> the reinitialization is necessary.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Applied, thanks.
