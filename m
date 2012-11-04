From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: inet_diag -- Return error code if protocol
 handler is missed
Date: Sun, 04 Nov 2012 01:57:11 -0400 (EDT)
Message-ID: <20121104.015711.1494281146432594398.davem@davemloft.net>
References: <20121103193034.GF6055@moon>
	<5095C747.7090805@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gorcunov@openvz.org, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34368 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750775Ab2KDF5P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Nov 2012 01:57:15 -0400
In-Reply-To: <5095C747.7090805@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@parallels.com>
Date: Sun, 04 Nov 2012 05:39:19 +0400

> On 11/03/2012 11:30 PM, Cyrill Gorcunov wrote:
>> We've observed that in case if UDP diag module is not
>> supported in kernel the netlink returns NLMSG_DONE without
>> notifying a caller that handler is missed.
>> 
>> This patch makes __inet_diag_dump to return error code instead.
>> 
>> So as example it become possible to detect such situation
>> and handle it gracefully on userspace level.
>> 
>> Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
>> CC: David Miller <davem@davemloft.net>
>> CC: Eric Dumazet <eric.dumazet@gmail.com>
>> CC: Pavel Emelyanov <xemul@parallels.com>
> 
> Acked-by: Pavel Emelyanov <xemul@parallels.com>

Applied, thanks.
