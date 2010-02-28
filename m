From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 2/2] mq: preserve queue mapping with
 bonding and VLAN devices
Date: Sun, 28 Feb 2010 01:33:11 -0800 (PST)
Message-ID: <20100228.013311.242139140.davem@davemloft.net>
References: <272541267277332@webmail86.yandex.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sysoleg@yandex.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37792
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1031664Ab0B1Jcw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2010 04:32:52 -0500
In-Reply-To: <272541267277332@webmail86.yandex.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "\"Oleg A. Arkhangelsky\"" <sysoleg@yandex.ru>
Date: Sat, 27 Feb 2010 16:28:52 +0300

> Forwarded packet goes through dev_queue_xmit() more that once
> when using bonding or 802.1q VLAN devices, so we've lost rx-tx
> queue mapping index for real devices. This is because initial
> queue index value (as it recorded by skb_record_tx_queue()) is
> overwritten by skb_set_queue_mapping(). 
> 
> Signed-off-by: Oleg A. Arkhangelsky <sysoleg@yandex.ru> 

Applied, thanks Oleg.

Patch #1 still needs work, please address Eric Dumazet's feedback.

Thanks!
