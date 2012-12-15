From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: Change defaults on cookie hmac selection
Date: Fri, 14 Dec 2012 20:14:26 -0500 (EST)
Message-ID: <20121214.201426.1300133389027142871.davem@davemloft.net>
References: <20121215003844.GA10508@neilslaptop.think-freely.org>
	<CA+55aFw-D2J-S8gH0PxO52nDeK31KHxum2gfT8RrzRoNF93yrg@mail.gmail.com>
	<20121215011229.GD10508@neilslaptop.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, netdev@vger.kernel.org,
	vyasevich@gmail.com, linux-sctp@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53540 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932151Ab2LOBO1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2012 20:14:27 -0500
In-Reply-To: <20121215011229.GD10508@neilslaptop.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Fri, 14 Dec 2012 20:12:29 -0500

> On Fri, Dec 14, 2012 at 04:44:56PM -0800, Linus Torvalds wrote:
>> On Fri, Dec 14, 2012 at 4:38 PM, Neil Horman <nhorman@tuxdriver.com> wrote:
>> >
>> > No need, I think.  Since its a user configurable choice now, the user can just
>> > set the selector to "None" in proc, and none will be used.
>> 
>> Well, by the same logic, there's no point to defaulting to MD5 either,
>> since the user could just put MD5 in the there.
>> 
>> The point is, if you're asking for a default, you should include the
>> actual choices, and not limit it to some random subset of choices. No?
>> 
>>              Linus
>> 
> Ok, Thats a fair point, I can add a option to choose the "None" option as the
> deafult.  Dave, do you want a delta patch, or a new version?

New version please.
