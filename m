From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/3] r8152: use mutex for hw settings
Date: Thu, 09 Oct 2014 19:06:32 -0400 (EDT)
Message-ID: <20141009.190632.1109121162247372029.davem@davemloft.net>
References: <1394712342-15778-58-Taiwan-albertk@realtek.com>
	<1394712342-15778-60-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43744 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750918AbaJIXGe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2014 19:06:34 -0400
In-Reply-To: <1394712342-15778-60-Taiwan-albertk@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hayes Wang <hayeswang@realtek.com>
Date: Thu, 9 Oct 2014 18:00:23 +0800

> v2:
> Make sure the autoresume wouldn't occur inside the mutex, otherwise
> the dead lock would happen. For the purpose, adjust some code about
> autosuspend/autoresume.
> 
> v1:
> Use mutex to avoid that the serial hw settings would be interrupted
> by other settings. Although there is no problem now, it makes the
> driver more safe.

Series applied, thanks.
