From: Julien Grall <julien.grall@citrix.com>
Subject: Re: [PATCH v4 3/3] net/xen-netback: Don't mix hexa and decimal with
 0x in the printf format
Date: Wed, 17 Jun 2015 10:30:39 +0100
Message-ID: <55813E3F.8030602@citrix.com>
References: <1434481848-26387-1-git-send-email-julien.grall@citrix.com>
	 <1434481848-26387-4-git-send-email-julien.grall@citrix.com>
 <1434533143.13744.273.camel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xenproject.org>, <linux-kernel@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>, <netdev@vger.kernel.org>
To: Ian Campbell <ian.campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:2020 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751622AbbFQJbF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2015 05:31:05 -0400
In-Reply-To: <1434533143.13744.273.camel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ian,

On 17/06/2015 10:25, Ian Campbell wrote:
> On Tue, 2015-06-16 at 20:10 +0100, Julien Grall wrote:
>> Append 0x to all %x in order to avoid while reading when there is other
>> decimal value in the log.
>>
>> Also replace some of the hexadecimal print to decimal to uniformize the
>> format with netfront.
>>
>> Signed-off-by: Julien Grall <julien.grall@citrix.com>
>> Cc: Wei Liu <wei.liu2@citrix.com>
>> Cc: Ian Campbell <ian.campbell@citrix.com>
>> Cc: netdev@vger.kernel.org
>
> You meant s/Append/Prepend/, nonetheless:

I noticed a missing word after "avoid" in the commit message too. I will 
update to:

"Prepend 0x to all %x in order to avoid confusion while reading when 
there is other decimal value in the log.

[...]".

>
> Acked-by: Ian Campbell <ian.campbell@citrix.com>

I see different opinion on whether using 0x% or %#. As I plan to resend 
a version with the commit message update, shall I use %#?

Regards,

-- 
Julien Grall
