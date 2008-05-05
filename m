From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2][BRIDGE]: Net device leak in br_add_bridge().
Date: Sun, 04 May 2008 17:57:36 -0700 (PDT)
Message-ID: <20080504.175736.178493567.davem@davemloft.net>
References: <481D5C01.30906@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37186
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751671AbYEEA5h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2008 20:57:37 -0400
In-Reply-To: <481D5C01.30906@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Sun, 04 May 2008 10:47:29 +0400

> In case the register_netdevice() call fails the device is leaked,
> since the out: label is just rtnl_unlock()+return.
> 
> Free the device.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
