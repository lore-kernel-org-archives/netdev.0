From: David Miller <davem@davemloft.net>
Subject: Re: regression: tethering fails in 3.5 with iwlwifi
Date: Thu, 21 Mar 2013 17:24:13 -0400 (EDT)
Message-ID: <20130321.172413.2290545724109237204.davem@davemloft.net>
References: <1347640763.5263.24.camel@sauron.fi.intel.com>
	<1347892887.7112.9.camel@sauron.fi.intel.com>
	<1363894451.8181.4.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: artem.bityutskiy@linux.intel.com, patrik.flykt@intel.com,
	edumazet@google.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, stable@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47235 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753451Ab3CUVYP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 17:24:15 -0400
In-Reply-To: <1363894451.8181.4.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Thu, 21 Mar 2013 20:34:11 +0100

> On Mon, 2012-09-17 at 17:41 +0300, Artem Bityutskiy wrote:
> 
>> OK, finally I got it. After 3 days of hardcore intelligent bisecting
>>         I've found out that tethering in 3.5 works for me if I revert
>> these 2
>>         patches:
>>         
>>             56138f5 iwlwifi: dont pull too much payload in skb head
> 
> I got back to this for a customer running 3.5, and after many failed
> attempts realized that you have to have iptables for this problem to
> actually happen. I reverse-bisected that the *fix* is
> 6caab7b0544e83e6c160b5e80f5a4a7dd69545c7, in 3.7.
> 
> Is there still any stable kernel 3.5/3.6 (or possibly before, though for
> iwlwifi before doesn't matter) that this should be applied to?

I've checked all of 3.0.x, 3.2.x, 3.4.x, and 3.8.x   They all have this
patch applied.

Those are the official stable kernels, everything else is outside of my
realm.
