From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: ping: small changes
Date: Sun, 15 May 2011 01:22:34 -0400 (EDT)
Message-ID: <20110515.012234.982722574809279361.davem@davemloft.net>
References: <1305363559.3120.54.camel@edumazet-laptop>
	<20110514143405.GA7599@albatros>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: segoon@openwall.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53775 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751549Ab1EOFXC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 May 2011 01:23:02 -0400
In-Reply-To: <20110514143405.GA7599@albatros>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasiliy Kulikov <segoon@openwall.com>
Date: Sat, 14 May 2011 18:34:05 +0400

> On Sat, May 14, 2011 at 10:59 +0200, Eric Dumazet wrote:
>> ping_table is not __read_mostly, since it contains one rwlock,
>> and is static to ping.c
>> 
>> ping_port_rover & ping_v4_lookup are static
>> 
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> 
> Acked-by: Vasiliy Kulikov <segoon@openwall.com>

Applied, thanks.
