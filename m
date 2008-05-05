From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2][ATM]: Do not free already unregistered net device.
Date: Sun, 04 May 2008 18:00:14 -0700 (PDT)
Message-ID: <20080504.180014.239539406.davem@davemloft.net>
References: <481D67C7.5050909@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37198
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753172AbYEEBAO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2008 21:00:14 -0400
In-Reply-To: <481D67C7.5050909@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Sun, 04 May 2008 11:37:43 +0400

> Both br2684_push and br2684_exit do so, but unregister_netdev()
> releases the device itself.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied, thanks.
