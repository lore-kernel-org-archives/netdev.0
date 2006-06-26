From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/6] netpoll: don't spin forever sending to stopped
 queues
Date: Mon, 26 Jun 2006 00:03:48 -0700 (PDT)
Message-ID: <20060626.000348.106265047.davem@davemloft.net>
References: <200606250847.k5P8lThc020900@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeremy@goop.org, mpm@selenic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:18879
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932158AbWFZHDv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jun 2006 03:03:51 -0400
To: akpm@osdl.org
In-Reply-To: <200606250847.k5P8lThc020900@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@osdl.org
Date: Sun, 25 Jun 2006 01:47:29 -0700

> 
> From: Jeremy Fitzhardinge <jeremy@goop.org>
> 
> When transmitting a skb in netpoll_send_skb(), only retry a limited number
> of times if the device queue is stopped.
> 
> Signed-off-by: Jeremy Fitzhardinge <jeremy@goop.org>
> Acked-by: Matt Mackall <mpm@selenic.com>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

Applied, thanks.
