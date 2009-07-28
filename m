From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: shrink net_device by #ifdef-ing protocol-specific
 members
Date: Tue, 28 Jul 2009 10:28:08 -0700 (PDT)
Message-ID: <20090728.102808.228535949.davem@davemloft.net>
References: <4A6DC314.2010303@ixiacom.com>
	<20090727.082644.265102452.davem@davemloft.net>
	<200907281743.27871.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lgrijincu@ixiacom.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: opurdila@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44972
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752730AbZG1R2B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 13:28:01 -0400
In-Reply-To: <200907281743.27871.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Octavian Purdila <opurdila@ixiacom.com>
Date: Tue, 28 Jul 2009 17:43:27 +0300

> On Monday 27 July 2009 18:26:44 David Miller wrote:
> 
>> This benefits, at best, %0.000000001 of users of the Linux kernel,
>> because every distribution is going to turn on every single option.
>>
> 
> Not all Linux users are using regular (desktop/server) distributions.

I didn't say all, I said "nearly all" which for many considerations
is roughly equivalent.

That %0.0000000001 was meant to represent non-distribution users.
