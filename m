From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: mac80211-next 2015-05-06
Date: Mon, 11 May 2015 10:41:02 -0400 (EDT)
Message-ID: <20150511.104102.520345911968274714.davem@davemloft.net>
References: <20150509.172803.2129151083625591640.davem@davemloft.net>
	<20150509.173446.1826713590855601099.davem@davemloft.net>
	<1431333103.1964.4.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34507 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751208AbbEKOlH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 10:41:07 -0400
In-Reply-To: <1431333103.1964.4.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Mon, 11 May 2015 10:31:43 +0200

> On Sat, 2015-05-09 at 17:34 -0400, David Miller wrote:
> 
>> Johhannes, the hash table size Kconfig entry absolutely not appropriate.
>> 
>> If anything, it should be hidden behind the strongest possible "DEBUG
>> ONLY" type dependencies, so that the user is never prompted for this
>> confusing option.
> 
> Hmm. It's hidden behind "MAC80211_DEBUG_MENU", which already should be
> discouragement, there's nothing in there that the user should ever
> select unless they're developing/debugging on this.
> 
> I can word the help text more strongly, perhaps? Or make the debug menu
> also depend on CONFIG_EXPERT (but most people seem to set that
> anyway ...)?
> 
> I'm happy to change this, but am not entirely sure how to discourage its
> use any further than we already do. Any suggestions?

Ok, this is actually my bad.

I keep forgetting that by doing allmodconfig builds all the time, I get
the debug options too. :-)
