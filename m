From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v1 0/4] net: fec: Code cleanup
Date: Sun, 28 Sep 2014 13:43:19 -0700
Message-ID: <542872E7.1020609@gmail.com>
References: <1411458058-18934-1-git-send-email-b38611@freescale.com>	<20140926.160602.1429816882470314568.davem@davemloft.net>	<ea65c2c86f264e49940038df21121c9e@BLUPR03MB373.namprd03.prod.outlook.com> <20140927.185501.2157704066172736196.davem@davemloft.net> <1779baf41a334eada2d11db0a474641b@BY2PR03MB377.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>
To: "fugang.duan@freescale.com" <fugang.duan@freescale.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:32803 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753458AbaI1UnW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Sep 2014 16:43:22 -0400
Received: by mail-pd0-f176.google.com with SMTP id fp1so2983897pdb.21
        for <netdev@vger.kernel.org>; Sun, 28 Sep 2014 13:43:22 -0700 (PDT)
In-Reply-To: <1779baf41a334eada2d11db0a474641b@BY2PR03MB377.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/27/14 20:39, fugang.duan@freescale.com wrote:
> From: David Miller <davem@davemloft.net> Sent: Sunday, September 28, 2014 6:55 AM
>> To: Duan Fugang-B38611
>> Cc: netdev@vger.kernel.org; Li Frank-B20596
>> Subject: Re: [PATCH v1 0/4] net: fec: Code cleanup
>>
>> From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
>> Date: Sat, 27 Sep 2014 09:51:52 +0000
>>
>>> From: David Miller <davem@davemloft.net> Sent: Saturday, September 27,
>>> 2014 4:06 AM
>>>> To: Duan Fugang-B38611
>>>> Cc: netdev@vger.kernel.org; Li Frank-B20596
>>>> Subject: Re: [PATCH v1 0/4] net: fec: Code cleanup
>>>>
>>>> From: Fugang Duan <b38611@freescale.com>
>>>> Date: Tue, 23 Sep 2014 15:40:54 +0800
>>>>
>>>>> This patches does several things:
>>>>>    - Fixing multiqueue issue.
>>>>>    - Removing the unnecessary errata workaround.
>>>>>    - Aligning the data buffer dma map/unmap size.
>>>>>    - Freeing resource after probe failed.
>>>>
>>>> Series applied to net-next, thanks.
>>>>
>>>> Please always explicitly state what tree you expect your patches to be
>>>> applied to in the future.
>>>
>>> No special requirement, just follow the normal rel flow.
>>
>> That doesn't mean anything to me.
>>
>> You must state what tree your patches apply properly to, and thus where
>> you expect them to be intergrated.
>
> I see. It is better let them enter to 3.17 (rc7).

They are not bugfixes, so they should target David's net-next tree, 
which will be pulled by Linus during the v3.18 merge window in the next 
few days.

Stuff that really needs to be fixed for 3.17 need to target David's net 
tree.
--
Florian
