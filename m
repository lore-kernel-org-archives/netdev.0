From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH] tcp repair: Fix unaligned access when repairing options
 (v2)
Date: Thu, 26 Apr 2012 13:41:14 +0400
Message-ID: <4F99183A.7010204@parallels.com>
References: <4F990C71.3020500@parallels.com> <20120426.052336.664675835426476301.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David.Laight@ACULAB.COM" <David.Laight@ACULAB.COM>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:25974 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751827Ab2DZJlY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2012 05:41:24 -0400
In-Reply-To: <20120426.052336.664675835426476301.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/26/2012 01:23 PM, David Miller wrote:
> From: Pavel Emelyanov <xemul@parallels.com>
> Date: Thu, 26 Apr 2012 12:50:57 +0400
> 
>> Don't pick __u8/__u16 values directly from raw pointers, but instead use
>> an array of structures of code:value pairs. This is OK, since the buffer
>> we take options from is not an skb memory, but a user-to-kernel one.
>>
>> For those options which don't require any value now, require this to be
>> zero (for potential future extension of this API).
>>
>> v2: Changed tcp_repair_opt to use two __u32-s as spotted by David Laight.
>>
>> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
> 
> Hmmm, this didn't show up on netdev, I wonder why?

So do I :( I haven't received any mail with errors from netdev, neither
Parallels mail server reported any problems.

I will resubmit this one again.

Thanks,
Pavel
