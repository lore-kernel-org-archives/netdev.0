From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2][ATM]: Bad locking on br2684_devs modifications.
Date: Sun, 04 May 2008 18:00:46 -0700 (PDT)
Message-ID: <20080504.180046.29624560.davem@davemloft.net>
References: <481D6814.6050801@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37202
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752731AbYEEBAq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2008 21:00:46 -0400
In-Reply-To: <481D6814.6050801@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Sun, 04 May 2008 11:39:00 +0400

> The list_del happens under read-locked devs_lock.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied, thanks a lot.
