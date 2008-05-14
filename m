From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][PPP]: Do not free not yet unregistered net device.
Date: Tue, 13 May 2008 23:51:29 -0700 (PDT)
Message-ID: <20080513.235129.98134067.davem@davemloft.net>
References: <4829B42A.8070005@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46364
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751835AbYENGvg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 02:51:36 -0400
In-Reply-To: <4829B42A.8070005@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 13 May 2008 19:30:50 +0400

> An error path in ppp_create_interface() lacks one and may
> BUG in free_netdev() checking for proper dev->reg_state.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied, thanks a lot Pavel.
