From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/2] ethtool: RXHASH flag support
Date: Tue, 30 Mar 2010 18:58:16 -0400
Message-ID: <4BB28208.4060100@garzik.org>
References: <20100328154448.701c89ee@nehalam>	<20100329174727.4654e19c@nehalam>	<20100329175352.38008e05@nehalam>	<4BB234DD.9040800@garzik.org>	<20100330103207.7fc5681a@nehalam>	<4BB236C9.7080300@garzik.org>	<20100330140519.7b45cbb6@nehalam>	<4BB26860.2040000@garzik.org> <20100330143133.709f542b@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:57590 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751285Ab0C3W6U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 18:58:20 -0400
Received: by pwi5 with SMTP id 5so8241514pwi.19
        for <netdev@vger.kernel.org>; Tue, 30 Mar 2010 15:58:19 -0700 (PDT)
In-Reply-To: <20100330143133.709f542b@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/30/2010 05:31 PM, Stephen Hemminger wrote:
> On Tue, 30 Mar 2010 17:08:48 -0400
> Jeff Garzik<jeff@garzik.org>  wrote:
>
>> On 03/30/2010 05:05 PM, Stephen Hemminger wrote:
>>> On Tue, 30 Mar 2010 13:37:13 -0400
>>> Jeff Garzik<jeff@garzik.org>   wrote:
>>>
>>>> On 03/30/2010 01:32 PM, Stephen Hemminger wrote:
>>>>> On Tue, 30 Mar 2010 13:29:01 -0400
>>>>> Jeff Garzik<jeff@garzik.org>    wrote:
>>>>>
>>>>>> By blindly sync'ing the ethtool.h header, ETHTOOL_MAX_NTUPLE_LIST_ENTRY
>>>>>> and its sibling ETHTOOL_MAX_NTUPLE_STRING_PER_ENTRY were removed,
>>>>>> breaking the ethtool build.
>>>>>
>>>>> In the patch I moved it to ethtool.c to have local entries.
>>>>>
>>>>> I believe that all cloned headers should only come from the result
>>>>> of kernel "make install_headers".  Not locally different vrsions.
>>>>
>>>> There is nothing locally different about ethtool-copy.h.
>>>>
>>>> 	Jeff
>>>
>>> diff -u ethtool-copy.h ~/kernel/net-next-2.6/usr/include/linux/ethtool.h
>>> --- ethtool-copy.h	2010-03-30 14:03:45.000000000 -0700
>>> +++ /home/shemminger/kernel/net-next-2.6/usr/include/linux/ethtool.h	2010-03-30 14:04:30.893866057 -0700
>>
>> The canonical copy of ethtool-copy.h comes from the kernel tree's
>> include/linux/ethtool.h.
>>
>
> The difference comes because scripts/headers_install.pl decides to change inline to __inline__.
> I think Kbuild is the proper place to do any exported headers cleanup, so I would
> rather the automated process work.

Either way, it's a manual process to sync up -- except that grabbing 
from $somewhere/usr/include/linux/ethtool.h involves more steps and is 
potentially more error-prone.

And regardless of any of this, none of the sync-up stuff should have 
been in the same patch as your RXHASH additions.

Now that ethtool.git has the latest from net-next, it's a moot point anyway.

	Jeff



