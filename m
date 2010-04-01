From: =?UTF-8?B?IllPU0hJRlVKSSBIaWRlYWtpICjlkInol6Qg6Iux5piOKSI=?=
	<hideaki@yoshifuji.org>
Subject: Re: [PATCH] xtables: make XT_ALIGN() usable in exported headers
Date: Thu, 01 Apr 2010 21:25:25 +0900
Message-ID: <4BB490B5.1040200@yoshifuji.org>
References: <n2ib6fcc0a1004010502z8c25a68cg11c5aa2f90ad4826@mail.gmail.com> <4BB48C50.2000000@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Andreas Henriksson <andreas@fatal.se>, jamal <hadi@cyberus.ca>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:53137 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754453Ab0DAM0D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 08:26:03 -0400
In-Reply-To: <4BB48C50.2000000@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I think it is better to solicit comments on LKML.

This is not a new issue but rather a common one
(e.g. CMSG_ALIGN uses its own definition).

Regards,

--yoshfuji

(2010/04/01 21:06), Patrick McHardy wrote:
> Alexey Dobriyan wrote:
>> On Thu, Apr 1, 2010 at 1:50 PM, Patrick McHardy<kaber@trash.net>  wrote:
>>> I can't think of anything but to restore the XT_ALIGN macro.
>>> We could add a XT_ALIGN definition to xtables.h, but that might
>>> still leave problems for other users.
>>>
>>> Alexey, do you have any better suggestions?
>>
>> I like __KERNEL_ALIGN trick.
>>
>> Sorry for attachment, my patch sending facility is broke.
>> Tested on iptables compilation.
>>
>
> Seems fine to me, thanks. I'll wait a bit for others to comment.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

