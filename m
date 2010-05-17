From: Ben Greear <greearb@candelatech.com>
Subject: Re: iproute2 issue with adding rules.
Date: Mon, 17 May 2010 13:34:29 -0700
Message-ID: <4BF1A855.3090905@candelatech.com>
References: <4BF192F9.8000008@candelatech.com> <4BF1A352.5020500@candelatech.com> <4BF1A6D1.70507@candelatech.com> <20100517203004.GD8301@sequoia.sous-sol.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Chris Wright <chrisw@sous-sol.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:46973 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753348Ab0EQUgK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 May 2010 16:36:10 -0400
In-Reply-To: <20100517203004.GD8301@sequoia.sous-sol.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/17/2010 01:30 PM, Chris Wright wrote:
> * Ben Greear (greearb@candelatech.com) wrote:
>> On 05/17/2010 01:13 PM, Ben Greear wrote:
>>> On 05/17/2010 12:03 PM, Ben Greear wrote:
>>>> On older releases, you can do this with iproute:
>>>>
>>>> # ip ru add from 9.9.9.2/32 table 226 pref 400
>>>> #
>>>>
>>>> But, in latest git, it returns an error:
>>>> # ip ru add from 9.9.9.2/32 table 226 pref 400
>>>> Error: an inet prefix is expected rather than "9.9.9.2/32".
>>>>
>>>> Is that on purpose?
>>>
>>> I was thinking maybe this was a library issue, since I compiled
>>> on one machine and ran the 'ip' exe on another. So, I tried compiling
>>> on the test system.
>>
>> I'm not thinking too well today, but this patch fixes the compile.
>> No idea if it's actually correct code.
>
> Needs more changes than that patch.

Ok, I'll try going back a few commits to find something that compiles
w/out my hacks.

Also, the rule addition does work..make install put ip in
a different place than it's installed in fedora, so I wasn't
actually running the latest code when I first tried to add
the rule.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

