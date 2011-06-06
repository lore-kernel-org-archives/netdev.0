From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ipv6: check for mistakenly passed in non-AF_INET6
 sockaddrs
Date: Mon, 06 Jun 2011 14:48:40 -0700 (PDT)
Message-ID: <20110606.144840.2081848600203422492.davem@davemloft.net>
References: <20110601.210359.2079286191194442010.davem@davemloft.net>
	<alpine.LNX.2.00.1106061538210.13876@nitsch.suse.de>
	<20110606160007.GD28535@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: max@suse.de, netdev@vger.kernel.org
To: meissner@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60260 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756131Ab1FFVsq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 17:48:46 -0400
In-Reply-To: <20110606160007.GD28535@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcus Meissner <meissner@suse.de>
Date: Mon, 6 Jun 2011 18:00:07 +0200

> On Mon, Jun 06, 2011 at 03:47:30PM +0200, Reinhard Max wrote:
>> 
>> On Wed, 1 Jun 2011 at 21:03, David Miller wrote:
>> 
>> >Since we haven't been validating the sin_family field for 18+ years, 
>> >the chance to break some applications is very real.
>> >
>> >But I think it's more important to fix this (and force any broken 
>> >apps to set sin_family correctly).  So I will apply this, thanks.
>> 
>> I think a corresponding check should also go into inet6_bind() in 
>> net/ipv6/af_inet6.c .
> 
> Good idea,
> 
> Same check as for IPv4, also do for IPv6.
> 
> (If you passed in a IPv4 sockaddr_in here, the sizeof check
>  in the line before would have triggered already though.)
> 
> Signed-off-by: Marcus Meissner <meissner@suse.de>
> Cc: Reinhard Max <max@suse.de>

Applied, thanks.
