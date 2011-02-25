From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sysctl: ipv6: use correct net in
 ipv6_sysctl_rtcache_flush
Date: Fri, 25 Feb 2011 11:02:25 -0800 (PST)
Message-ID: <20110225.110225.183034283.davem@davemloft.net>
References: <1298612883-18762-1-git-send-email-lucian.grijincu@gmail.com>
	<4D67CB11.4020801@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lucian.grijincu@gmail.com, netdev@vger.kernel.org,
	benjamin.thery@bull.net
To: daniel.lezcano@free.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59414
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751325Ab1BYTBs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 14:01:48 -0500
In-Reply-To: <4D67CB11.4020801@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <daniel.lezcano@free.fr>
Date: Fri, 25 Feb 2011 16:30:25 +0100

> On 02/25/2011 06:48 AM, Lucian Adrian Grijincu wrote:
>> Before this patch issuing these commands:
>>
>>    fd = open("/proc/sys/net/ipv6/route/flush")
>>    unshare(CLONE_NEWNET)
>>    write(fd, "stuff")
>>
>> would flush the newly created net, not the original one.
>>
>> The equivalent ipv4 code is correct (stores the net inside ->extra1).
>> ---
> 
> Acked-by: Daniel Lezcano <daniel.lezcano@free.fr>

Applied, thanks.
