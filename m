From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ethtool.h: Add "structs are public" disclaimer comment
Date: Sun, 14 Mar 2010 14:38:19 -0400
Message-ID: <4B9D2D1B.2080004@garzik.org>
References: <20100314014335.GA17208@serverengines.com>	 <20100313.181145.211264593.davem@davemloft.net>	 <1268583478.30289.94.camel@Joe-Laptop.home> <1268589034.2664.68.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>,
	ajitk@serverengines.com, ajitkhaparde@gmail.com,
	netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:59467 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759569Ab0CNSiY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Mar 2010 14:38:24 -0400
Received: by gyg8 with SMTP id 8so1069638gyg.19
        for <netdev@vger.kernel.org>; Sun, 14 Mar 2010 11:38:22 -0700 (PDT)
In-Reply-To: <1268589034.2664.68.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/14/2010 01:50 PM, Ben Hutchings wrote:
> On Sun, 2010-03-14 at 09:17 -0700, Joe Perches wrote:
>> On Sat, 2010-03-13 at 18:11 -0800, David Miller wrote:
>>> For the millionth time, you cannot change these datastructures
>>> like this without breaking all existing userspace applications
>>> out there.
>>
>> Maybe this might help reduce the broken record repetitiveness.
>>
>> Signed-off-by: Joe Perches<joe@perches.com>
>> ---
>> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
>> index b33f316..9bd7583 100644
>> --- a/include/linux/ethtool.h
>> +++ b/include/linux/ethtool.h
>> @@ -10,6 +10,15 @@
>>    * Portions Copyright (C) Sun Microsystems 2008
>>    */
>>
>> +/*
>> + * Do not submit patches that change the public structs not guarded by
>> + * #ifdef __KERNEL__ in this file.
>> + *
>> + * In case the use of __u8, __u16, __u32 and other reserved types don't
>> + * mean much to you, these structs are used by user-space applications
>> + * and must not be changed.
>> + */
>
> This comment is not quite correct: reserved fields may be replaced so
> long as the structure size and offsets of other fields stay the same.

I don't think we need this in every ABI-related header, though, do we?

	Jeff




