From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: mac80211-next 2015-05-06
Date: Sat, 09 May 2015 17:34:46 -0400 (EDT)
Message-ID: <20150509.173446.1826713590855601099.davem@davemloft.net>
References: <1430920780.1954.10.camel@sipsolutions.net>
	<1430920954.1954.11.camel@sipsolutions.net>
	<20150509.172803.2129151083625591640.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45692 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751129AbbEIVes (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 17:34:48 -0400
In-Reply-To: <20150509.172803.2129151083625591640.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Sat, 09 May 2015 17:28:03 -0400 (EDT)

> From: Johannes Berg <johannes@sipsolutions.net>
> Date: Wed, 06 May 2015 16:02:34 +0200
> 
>> On Wed, 2015-05-06 at 15:59 +0200, Johannes Berg wrote:
>>> Hi Dave,
>>> 
>>> This is the first -next pull request for my mac80211-next tree. See
>>> below for what's in it - there isn't that much.
>>> 
>>> Please let me know if there are any issues.
>> 
>> Oops, I found one - amended pull request just adds one patch to fix a
>> docbook problem.
> 
> Pulled, thanks Johannes.

Johhannes, the hash table size Kconfig entry absolutely not appropriate.

If anything, it should be hidden behind the strongest possible "DEBUG
ONLY" type dependencies, so that the user is never prompted for this
confusing option.

Thanks.
