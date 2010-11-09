From: Ben Greear <greearb@candelatech.com>
Subject: Re: Networking hangs when too many parallel requests are made at
 once
Date: Tue, 09 Nov 2010 12:35:39 -0800
Message-ID: <4CD9B09B.8040906@candelatech.com>
References: <AANLkTikuCj=saH34dyO6xnU-y8rWv63hJaqowZ0ACLzk@mail.gmail.com> <AANLkTinRo_ozWFCYYqanOh0YrTJ6+KadutG2j7T726dY@mail.gmail.com> <4CD99E20.4060307@candelatech.com> <AANLkTinz6C4s3wX7t6CsE2bzZ2adCoi0RAcqvpEFE2GV@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Luke Hutchison <luke.hutch@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:34124 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754613Ab0KIUfl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 15:35:41 -0500
In-Reply-To: <AANLkTinz6C4s3wX7t6CsE2bzZ2adCoi0RAcqvpEFE2GV@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/09/2010 12:27 PM, Luke Hutchison wrote:
> On Tue, Nov 9, 2010 at 2:16 PM, Ben Greear<greearb@candelatech.com>  wrote:
>> On 11/09/2010 11:04 AM, Luke Hutchison wrote:
>>>
>>> On Tue, Nov 9, 2010 at 1:30 PM, Luke Hutchison<luke.hutch@gmail.com>
>>>   wrote:
>>>>
>>>> Since around Linux kernel 2.6.33 or so (but maybe as early as
>>>> 2.6.31, not sure exactly what version), when restoring a crashed or
>>>> closed browser session of either Firefox or Chrome where lots of tabs
>>>> (say 10-40) open simultaneously, the networking stack is brought to
>>>> its knees -- most or all the tabs eventually time out without data, or
>>>> a few tabs might get some data and then display a partial web page.
>>
>> Have you been able to reproduce this on any other machine?  I suspect
>> it might be an issue with your specific NIC or other hardware.
>>
>> At the least, it's not a general problem with opening lots
>> of TCP connections, as we routinely test with thousands...
>>
>> Thanks,
>> Ben
>
> No, I haven't been able to reproduce on any other machine.  But it
> happens on both my wifi NIC and my ethernet NIC in this machine.

Well, let us know what those are, at least.

And, a network capture of your system going into this state might
be useful.  I'd try to disable your wireless NIC entirely and focus
on debugging the wired NIC as that is usually easier to debug.

Thanks,
Ben

>
> Thanks,
> Luke


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

