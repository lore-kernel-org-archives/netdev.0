From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netxen: fix a race in netxen_nic_get_stats()
Date: Thu, 19 Aug 2010 00:44:32 -0700 (PDT)
Message-ID: <20100819.004432.146360151.davem@davemloft.net>
References: <1282128168.2194.49.camel@edumazet-laptop>
	<99737F4847ED0A48AECC9F4A1974A4B80F86E69124@MNEXMB2.qlogic.org>
	<1282134570.2194.53.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amit.salecha@qlogic.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53137
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751369Ab0HSHoN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 03:44:13 -0400
In-Reply-To: <1282134570.2194.53.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 18 Aug 2010 14:29:30 +0200

> Dont clear netdev->stats, it might give transient wrong values to
> concurrent stat readers.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Also applied, thanks Eric.
