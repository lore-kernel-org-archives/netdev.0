From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Rework dev_base via list_head (v3)
Date: Thu, 03 May 2007 17:17:35 -0700 (PDT)
Message-ID: <20070503.171735.131920857.davem@davemloft.net>
References: <463A00A6.6000100@sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, devel@openvz.org,
	dev@openvz.org
To: xemul@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41591
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1423471AbXEDARf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2007 20:17:35 -0400
In-Reply-To: <463A00A6.6000100@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelianov <xemul@sw.ru>
Date: Thu, 03 May 2007 19:32:54 +0400

> Netdev tree was updated today soon after I sent a patch for it,
> so this version applies to it and the fs/afs/netdevices.c file
> is added. Hope I am not late yet again :)
> 
> Cleanup of dev_base list use, with the aim to simplify making
> device list per-namespace. In almost every occasion, use of
> dev_base variable and dev->next pointer could be easily replaced
> by  for_each_netdev loop. A few most complicated places were
> converted to using first_netdev()/next_netdev().
> 
> Signed-off-by: Pavel Emelianov <xemul@openvz.org>
> Acked-by: Kirill Korotaev <dev@openvz.org>
> Cc: Patrick McHardy <kaber@trash.net>

Looks good, I've applied this, thanks!
