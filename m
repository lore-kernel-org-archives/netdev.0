From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] USB: gadget: fix ethernet gadget crash in gether_setup
Date: Thu, 28 Oct 2010 10:32:06 -0700 (PDT)
Message-ID: <20101028.103206.28805685.davem@davemloft.net>
References: <1288253909-12084-1-git-send-email-mad_soft@inbox.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, dbrownell@users.sourceforge.net,
	gregkh@suse.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, therbert@google.com
To: mad_soft@inbox.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34751
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751403Ab0J1Rbn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 13:31:43 -0400
In-Reply-To: <1288253909-12084-1-git-send-email-mad_soft@inbox.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Artamonow <mad_soft@inbox.ru>
Date: Thu, 28 Oct 2010 12:18:29 +0400

> Crash is triggered by commit e6484930d7 ("net: allocate tx queues in
> register_netdevice"), which moved tx netqueue creation into register_netdev.
> So now calling netif_stop_queue() before register_netdev causes an oops.
> Move netif_stop_queue() after net device registration to fix crash.
> 
> Signed-off-by: Dmitry Artamonow <mad_soft@inbox.ru>

Applied, thank you.
