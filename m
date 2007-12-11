From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Use BUILD_BUG_ON for tcp_skb_cb size checking
Date: Tue, 11 Dec 2007 02:12:14 -0800 (PST)
Message-ID: <20071211.021214.144569902.davem@davemloft.net>
References: <475985EC.6050608@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33125
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751528AbXLKKMP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 05:12:15 -0500
In-Reply-To: <475985EC.6050608@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Fri, 07 Dec 2007 20:42:04 +0300

> The sizeof(struct tcp_skb_cb) should not be less than the
> sizeof(skb->cb). This is checked in net/ipv4/tcp.c, but
> this check can be made more gracefully.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied to net-2.6.25, thanks.
