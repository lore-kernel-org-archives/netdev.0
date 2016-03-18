From: Luis de Bethencourt <luisbg@osg.samsung.com>
Subject: Re: [PATCH] mac80211: fix order of flag descriptions
Date: Fri, 18 Mar 2016 17:46:25 +0000
Message-ID: <56EC3EF1.50805@osg.samsung.com>
References: <1458317369-28185-1-git-send-email-luisbg@osg.samsung.com> <1458318955-32070-1-git-send-email-luisbg@osg.samsung.com> <1458319756.13729.1.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lists.s-osg.org ([54.187.51.154]:54694 "EHLO lists.s-osg.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932584AbcCRRq3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Mar 2016 13:46:29 -0400
In-Reply-To: <1458319756.13729.1.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18/03/16 16:49, Johannes Berg wrote:
> On Fri, 2016-03-18 at 16:35 +0000, Luis de Bethencourt wrote:
>> Fix order of mac80211_rx_flags description to match the enum.
>>
>> Signed-off-by: Luis de Bethencourt <luisbg@osg.samsung.com>
>> ---
>> Hi,
>>
>> I want ahead and fixed the order of the descriptions. checkpatch.pl
>> was giving
>> a warning to my previous patch and I had a hunch it was because the
>> wrong order
>> breaks the parser. Indeed it does and with this patch below
>> checkpatch.pl does
>> not complain about this flag descriptions anymore.
>>
> Huh. I think we should fix checkpatch.pl instead. While the current
> order isn't likely really good, I believe kernel-doc will output the
> documentation in the order it's listed, and that can be useful for the
> documentation output to group related things, even if their bits may be
> further apart.
> 
> johannes
> 

I agree checkpatch.pl should be fixed. I can look into it. No promises
though, it has been a long time since I look at Perl code.

I understand the logic of grouping the documentation in logical blocks.
It is unfortunate though that this means the enum and documentation won't
match, which makes reading the code harder.

In this particular case I don't see the order of the documentation broken
because flags are being grouped.

Thanks for the review :)
Luis
