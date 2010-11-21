From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] packet: use vzalloc()
Date: Sun, 21 Nov 2010 10:02:02 -0800 (PST)
Message-ID: <20101121.100202.189685994.davem@davemloft.net>
References: <1290274314.2756.84.camel@edumazet-laptop>
	<20101121004348.GA29311@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45191
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754743Ab0KUSBh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Nov 2010 13:01:37 -0500
In-Reply-To: <20101121004348.GA29311@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Sat, 20 Nov 2010 19:43:48 -0500

> On Sat, Nov 20, 2010 at 06:31:54PM +0100, Eric Dumazet wrote:
>> alloc_one_pg_vec_page() is supposed to return zeroed memory, so use
>> vzalloc() instead of vmalloc()
>> 
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> Cc: Neil Horman <nhorman@tuxdriver.com>
> Acked-by: Neil Horman <nhorman@tuxdriver.com>
> 
> Thanks Eric!

Applied, thanks everyone.
