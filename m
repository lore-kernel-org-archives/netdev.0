From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH 3/5] ucc_geth: eliminate max-speed, change interface-type to phy-connection-type
Date: Wed, 23 May 2007 08:18:30 -0500
Message-ID: <94EFC504-8A34-455D-8DB7-89708C404709@kernel.crashing.org>
References: <20070511182507.7642926e.kim.phillips@freescale.com> <464A29EF.7080405@garzik.org> <20070515172629.61c1b4c2.kim.phillips@freescale.com> <464D0721.4030600@garzik.org> <24CEBCE5-8E12-4D08-A657-24BA8688EE5D@kernel.crashing.org> <20070518103302.476b0f04.kim.phillips@freescale.com>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Kim Phillips <kim.phillips@freescale.com>,
	Andrew Morton <akpm@linux-foundation.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nommos.sslcatacombnetworking.com ([67.18.224.114]:29705 "EHLO
	nommos.sslcatacombnetworking.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754992AbXEWNUK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2007 09:20:10 -0400
In-Reply-To: <20070518103302.476b0f04.kim.phillips@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On May 18, 2007, at 10:33 AM, Kim Phillips wrote:

> On Fri, 18 May 2007 09:07:42 -0500
> Kumar Gala <galak@kernel.crashing.org> wrote:
>
>>
>> On May 17, 2007, at 8:53 PM, Jeff Garzik wrote:
>>
>>> Kim Phillips wrote:
>>>> On Tue, 15 May 2007 17:45:19 -0400
>>>> Jeff Garzik <jeff@garzik.org> wrote:
>>>>> Kim Phillips wrote:
>>>>>> It was agreed that phy-connection-type was a better name for
>>>>>> the interface-type property, so this patch renames it.
>>>>>>
>>>>>> Also, the max-speed property name was determined too generic,
>>>>>> and is therefore eliminated in favour of phy-connection-type
>>>>>> derivation logic.
>>>>>>
>>>>>> includes corrections to copyright text.
>>>>>>
>>>>>> Signed-off-by: Kim Phillips <kim.phillips@freescale.com>
>>>>>> ---
>>>>>>  drivers/net/ucc_geth.c     |   40 +++++++++++++++
>>>>>> +------------------------
>>>>>>  drivers/net/ucc_geth_mii.c |    9 +++++----
>>>>>>  drivers/net/ucc_geth_mii.h |   10 +++++-----
>>>>>>  3 files changed, 26 insertions(+), 33 deletions(-)
>>>>> applied to #upstream
>>>>>
>>>> just to be clear; only the mpc8323e-mds board works on your
>>>> current #upstream-{fixes,linus}.
>>>> The mpc8323e-rdb and mpc8360e-mds require
>>>> phylib: add the ICPlus IP175C PHY driver
>>>> and phylib: enable RGMII-ID on the Marvell m88e1111 PHY
>>>> respectively in order to work.
>>>> I'm ok with the SGMII patches:
>>>> phylib: m88e1111: enable SGMII mode
>>>> gianfar: add support for SGMII
>>>> staying on #upstream, but 2 out of 3 boards are currently broken
>>>> for #upstream-{fixes,linus}.
>>>
>>> New hardware support is always "broken" until merged.  Nonetheless
>>> it is still new and outside the merge window.
>>
>> I think new is a little relative here.  The MPC8232-RDB & MPC8360E-
>> MDS boards worked with 2.6.21 and the UCC. They had support for the
>> PHYs that Kim's listed built directly into the ucc driver and not as
>> part of the phy lib.  Since we've moved to using the phy lib in
>> 2.6.22 we've broken these boards since their PHY drivers aren't
>> currently in linus's tree.
>>
>> Kim, correct me if I'm wrong.
>>
>
> thanks for clarifying that - it is indeed the case.

Jeff, any comments?

While I can see the view that the ICPlus & m88e1111 in RGMII may be  
"new" Kim did post these patches before the release of 2.6.21.

http://marc.info/?l=linux-netdev&m=117624199831578&w=2
http://marc.info/?l=linux-netdev&m=117624199831578&w=2

And I believe its our normal stance to not introduce regressions  
between kernel versions when possible.  It would be appreciated if  
you could push the two patches Kim has referenced to linus for 2.6.22  
otherwise we've created a regression in supporting the MPC8323 RDB &  
MPC8360 MDS boards.

thanks

- k

