From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 09/15] ipv4: Cache output routes in fib_info nexthops.
Date: Thu, 19 Jul 2012 08:39:15 -0700 (PDT)
Message-ID: <20120719.083915.635511426151379834.davem@davemloft.net>
References: <20120718.112404.1910372180742347127.davem@davemloft.net>
	<20120719113810.GM1869@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45350 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750942Ab2GSPjQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 11:39:16 -0400
In-Reply-To: <20120719113810.GM1869@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Thu, 19 Jul 2012 13:38:10 +0200

> On Wed, Jul 18, 2012 at 11:24:04AM -0700, David Miller wrote:
>> +
>> +static void rt_bind_exception(struct rtable *rt, struct fib_nh_exception *fnhe)
>> +{
>> +	if (fnhe->fnhe_pmtu) {
>> +		unsigned long expires = fnhe->fnhe_expires;
>> +		unsigned long diff = jiffies - expires;
> 
> This should be diff = expires - jiffies
> 
> With that changed, everything seems to work fine :)

Thanks a lot for catching this bug, I'll fix it up right now.
