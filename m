From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: bcmgenet: Software reset EPHY after power on
Date: Thu, 05 Nov 2015 15:57:11 -0500 (EST)
Message-ID: <20151105.155711.377524744545112148.davem@davemloft.net>
References: <1446167495-3923-1-git-send-email-f.fainelli@gmail.com>
	<563946CE.8070706@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pgynther@google.com, jaedon.shin@gmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39145 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756606AbbKEU5N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2015 15:57:13 -0500
In-Reply-To: <563946CE.8070706@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue, 03 Nov 2015 15:44:14 -0800

> On 29/10/15 18:11, Florian Fainelli wrote:
>> The EPHY on GENET v1->v3 is extremely finicky, and will show occasional
>> failures based on the timing and reset sequence, ranging from duplicate
>> packets, to extremely high latencies.
>> 
>> Perform an additional software reset, and re-configuration to make sure it is
>> in a consistent and working state.
>> 
>> Fixes: 6ac3ce8295e6 ("net: bcmgenet: Remove excessive PHY reset")
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> 
> I see that you have applied this to your pull request sent to Linus
> today, could you also queue this for 4.3-stable? Thank you!

Done.
