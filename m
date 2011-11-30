From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] xfrm: add incoming interface to selector
Date: Wed, 30 Nov 2011 12:47:57 -0500 (EST)
Message-ID: <20111130.124757.2280987851734291034.davem@davemloft.net>
References: <1322511292-1413-2-git-send-email-ulrich.weber@sophos.com>
	<20111129.190037.1527680744377783412.davem@davemloft.net>
	<4ED66902.7060507@sophos.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ulrich.weber@Sophos.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53664 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750951Ab1K3RsB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 12:48:01 -0500
In-Reply-To: <4ED66902.7060507@sophos.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ulrich Weber <ulrich.weber@Sophos.com>
Date: Wed, 30 Nov 2011 18:33:54 +0100

> On 30.11.2011 01:00, David Miller wrote:
>>
>> This isn't safe, because we have no idea if existing users are putting
>> garbage there.  So your change can break things.
>>
>> You'll have to add a netlink attribute or similar.
> But a implementation matching xfrm against UID would break
> existing programs too, where sel->user is set to garbage.

Such a program would have to be used with other agents which are known
to not modify the sel->user of existing entries.

I'm not letting you reassign this existing structure member for another
use, it's been exposed to userspace for nearly 10 years.
