From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] net: Add fib rules at vrf device create
Date: Wed, 09 Dec 2015 17:22:07 -0500 (EST)
Message-ID: <20151209.172207.663308411545854156.davem@davemloft.net>
References: <1449683012-14145-1-git-send-email-dsa@cumulusnetworks.com>
	<20151209.151309.1866782058292162458.davem@davemloft.net>
	<5668A592.3080104@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shm@cumulusnetworks.com,
	roopa@cumulusnetworks.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41373 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751324AbbLIWWI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 17:22:08 -0500
In-Reply-To: <5668A592.3080104@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Wed, 9 Dec 2015 15:05:06 -0700

> On 12/9/15 1:13 PM, David Miller wrote:
>> The new attributes make things more complex, because ever _VALID_ tool
>> much accomodate the existing situation and be able to perform all of
>> the commands above if they are executed on an older kernel.
>>
>> So the new attributes make things worse, not better.
> 
> Dave, how does this make it more complex - beyond the complexity of
> giving a user choices?

You keep creating situations where the user has to do the whole thing
anyways, to accomodate older kernels that don't have the new attributes.

That's complexity.

Just write a script already...
