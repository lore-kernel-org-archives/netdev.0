From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netpoll: don't dereference NULL dev from np
Date: Sun, 17 May 2009 20:38:17 -0700 (PDT)
Message-ID: <20090517.203817.250076003.davem@davemloft.net>
References: <4A07FFB3.70308@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55136
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752334AbZERDiT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2009 23:38:19 -0400
In-Reply-To: <4A07FFB3.70308@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Mon, 11 May 2009 14:36:35 +0400

> It looks like the dev in netpoll_poll can be NULL - at lease it's 
> checked at the function beginning. Thus the dev->netde_ops dereference 
> looks dangerous.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Good catch, probably added by the netdev_ops changes.

Applied, thanks!
