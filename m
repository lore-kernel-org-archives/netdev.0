From: David Miller <davem@davemloft.net>
Subject: Re: Build error v3.9-rc when CONFIG_IPV6 configured as module
Date: Mon, 15 Apr 2013 13:30:59 -0400 (EDT)
Message-ID: <20130415.133059.752889111702097790.davem@davemloft.net>
References: <1366016535.8361.2.camel@jlt4.sipsolutions.net>
	<1366016677.8361.3.camel@jlt4.sipsolutions.net>
	<1366016729.8361.4.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tomas.melin@iki.fi, netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34136 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754901Ab3DORbB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 13:31:01 -0400
In-Reply-To: <1366016729.8361.4.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Mon, 15 Apr 2013 11:05:29 +0200

> On Mon, 2013-04-15 at 11:04 +0200, Johannes Berg wrote:
> 
>> > Oops, I didn't realize that IPv6 could even (still) be built as a
>> > module. I'll add this to mac80211's Kconfig:
>> > 	depends on IPV6 || !IPV6
>> > to fix this.
>> 
>> Hm, actually, that's not sufficient since there are no no-op versions of
>> these functions when IPv6 isn't built ... needs a bit more.
> 
> Oh, never mind, I already handle that case ... Should check the code
> before :)

Johannes, we already fixed this, see 'net'.  Don't add more hacks to
mac80211.
