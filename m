From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] can: should not use __dev_get_by_index() without locks
Date: Sun, 08 Nov 2009 00:34:25 -0800 (PST)
Message-ID: <20091108.003425.21973000.davem@davemloft.net>
References: <4AF3F905.4030608@gmail.com>
	<4AF402B0.7090202@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: socketcan@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33518
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752445AbZKHIeA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2009 03:34:00 -0500
In-Reply-To: <4AF402B0.7090202@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <socketcan@hartkopp.net>
Date: Fri, 06 Nov 2009 12:04:16 +0100

> Eric Dumazet wrote:
>> [PATCH] can: should not use __dev_get_by_index() without locks
>> 
>> bcm_proc_getifname() is called with RTNL and dev_base_lock
>> not held. It calls __dev_get_by_index() without locks, and
>> this is illegal (might crash)
>> 
>> Close the race by holding dev_base_lock and copying dev->name
>> in the protected section.
>> 
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
 ...
> Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>

Applied, thanks everyone.
