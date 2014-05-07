From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5] net: Use netlink_ns_capable to verify the
 permisions of netlink messages
Date: Wed, 07 May 2014 19:45:14 -0400 (EDT)
Message-ID: <20140507.194514.1312153135098382943.davem@davemloft.net>
References: <CALCETrXL6eui802diSCrzNEtVcA5f3W58kFj6h4DYobm3YR_JQ@mail.gmail.com>
	<20140507.185256.496391962242529591.davem@davemloft.net>
	<CALCETrVo7ducU3S25Z_4NDB1p72pSLU0oLQh-ppxEWMgqYyjqQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jorge@dti2.net, ebiederm@xmission.com, vgoyal@redhat.com,
	ssorce@redhat.com, security@kernel.org, netdev@vger.kernel.org,
	serge@hallyn.com
To: luto@amacapital.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52652 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751318AbaEGXpS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 19:45:18 -0400
In-Reply-To: <CALCETrVo7ducU3S25Z_4NDB1p72pSLU0oLQh-ppxEWMgqYyjqQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 7 May 2014 16:01:33 -0700

> On Wed, May 7, 2014 at 3:52 PM, David Miller <davem@davemloft.net> wrote:
>> From: Andy Lutomirski <luto@amacapital.net>
>> Date: Wed, 7 May 2014 15:26:11 -0700
>>
>>> So what do we do?  Check permissions on connect and then use the
>>> cached result for send on a connected socket?  Check permitted caps
>>> instead of effective caps?
>>
>> It should create the socket after changing perms.
> 
> I agree that it should, but it doesn't, and if these patches get
> backported, things will break.  OTOH, if the patches don't get
> backported, things may still break, and we have a possibly rather
> severe unfixed vulnerability.

I think the kernel change is justified as the privilege allowance
that happened before was very much unintentional and as you've
shown us countless times a very real problem that we must fix.
