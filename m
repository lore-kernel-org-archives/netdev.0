From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] inetpeer: fix token initialization
Date: Thu, 27 Sep 2012 19:28:07 -0400 (EDT)
Message-ID: <20120927.192807.86024736178134621.davem@davemloft.net>
References: <1348752886.5093.1282.camel@edumazet-glaptop>
	<1348755060-3737-1-git-send-email-nicolas.dichtel@6wind.com>
	<1348755516.5093.1326.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59625 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755299Ab2I0X2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 19:28:09 -0400
In-Reply-To: <1348755516.5093.1326.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 27 Sep 2012 16:18:36 +0200

> On Thu, 2012-09-27 at 16:11 +0200, Nicolas Dichtel wrote:
>> When jiffies wraps around (for example, 5 minutes after the boot, see
>> INITIAL_JIFFIES) and peer has just been created, now - peer->rate_last can be
>> < XRLIM_BURST_FACTOR * timeout, so token is not set to the maximum value, thus
>> some icmp packets can be unexpectedly dropped.
>> 
>> Fix this case by initializing last_rate to 60 seconds in the past.
>> 
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>> ---
>> v2: fix initialization of peer instead of adding some tests in
>>     inet_peer_xrlim_allow()
 ...
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks everyone.
