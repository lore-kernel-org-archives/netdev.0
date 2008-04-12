From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] [ETHTOOL]: Add support for large eeproms
Date: Sat, 12 Apr 2008 05:10:56 -0400
Message-ID: <48007CA0.6030002@garzik.org>
References: <20080403180021.GA5974@google.com> <1207267417.23161.353.camel@localhost> <20080404014129.GA28593@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	matthew@wil.cx, davem@davemloft.net, nil@google.com,
	thockin@google.com
To: Mandeep Singh Baines <msb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41657 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754018AbYDLJLB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Apr 2008 05:11:01 -0400
In-Reply-To: <20080404014129.GA28593@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mandeep Singh Baines wrote:
> Joe Perches (joe@perches.com) wrote:
>> This looks better.
>> There's a typo at line 315 though, it needs a ";".
>>
> 
> Oops. In my haste to get out the revised patch I didn't bother to test.
> Bad Mandeep.
> 
>> I was also wrong that int ret _does_ need to be
>> initialized to 0 in case (eeprom.len == 0)
>>
> 
> I knew I had that there for a reason. But I forgot to initialize ret in
> ethtool_get_eeprom. You've fixed this in your update to the patch:)
> 
>> I think this should be written as below:
>>
> 
> Agreed. You've fixed my bugs and I think setting ret inside the if
> makes the code easier to reason about.
> 
> I've tested your updated version of the patch and it looks good.
> 
>> cheers, Joe
>>
>>  net/core/ethtool.c |   68 +++++++++++++++++++++++++++++-----------------------
>>  1 files changed, 38 insertions(+), 30 deletions(-)

someone wanna resend with proper sign-offs?


