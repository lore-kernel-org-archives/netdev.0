From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/6] vxge: NETIF_F_LLTX removal
Date: Thu, 15 Jul 2010 20:50:56 -0700 (PDT)
Message-ID: <20100715.205056.27818327.davem@davemloft.net>
References: <1279219648-10345-3-git-send-email-jon.mason@exar.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ramkrishna.vepa@exar.com
To: jon.mason@exar.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60725
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935598Ab0GPDul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jul 2010 23:50:41 -0400
In-Reply-To: <1279219648-10345-3-git-send-email-jon.mason@exar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Mason <jon.mason@exar.com>
Date: Thu, 15 Jul 2010 13:47:25 -0500

> NETIF_F_LLTX and it's usage of local transmit locks are depricated in
> favor of using the netdev queue's transmit lock.  Remove the local
> lock and all references to it, and use the netdev queue transmit lock
> in the transmit completion handler.
> 
> Signed-off-by: Jon Mason <jon.mason@exar.com>
> Signed-off-by: Ramkrishna Vepa <ramkrishna.vepa@exar.com>

Thanks a lot for doing this work.

Applied.
