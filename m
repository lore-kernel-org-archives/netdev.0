From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH v2 2/2] can: spi: hi311x: Add Holt HI-311x CAN driver
Date: Fri, 17 Mar 2017 09:17:26 +0100
Message-ID: <803bd0fb-3e23-7b69-ced9-eca5553bf0fe@grandegger.com>
References: <1484680922-25813-1-git-send-email-akshay.bhat@timesys.com>
 <1484680922-25813-2-git-send-email-akshay.bhat@timesys.com>
 <234d9e75-0083-b8b4-c781-add653fdb550@grandegger.com>
 <b3ebb569-b50c-39ad-dec5-0059fbfba8fb@timesys.com>
 <eb4e0f6f-14de-3369-0d50-7371ae74f4fb@grandegger.com>
 <3dbf8748-9d04-0f21-0e95-448d7a72e7d5@timesys.com>
 <41439729-42d0-d883-2801-2d3607f2aeab@grandegger.com>
 <CANiP4c8WMeT1Cr7WDXew1ne7DFR04oaA8Uch0zvyyOf5yCa37A@mail.gmail.com>
 <3dba0948-ffcb-8e80-fb32-62bb0aca6627@grandegger.com>
 <54d9a104-8ed1-4bb3-666e-042d3781dbfb@timesys.com>
 <006d9e14-47bf-1add-97c3-24098b43267f@grandegger.com>
 <69173747-cc2e-55f7-acad-4b5ba2a22863@timesys.com>
 <d5182e77-c243-1980-4cb6-39cd95075f4f@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mkl@pengutronix.de, linux-can@vger.kernel.org,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Akshay Bhat <akshay.bhat@timesys.com>,
        Akshay Bhat <nodeax@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailproxy01.manitu.net ([217.11.48.65]:59880 "EHLO
        mailproxy01.manitu.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751029AbdCQISk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Mar 2017 04:18:40 -0400
In-Reply-To: <d5182e77-c243-1980-4cb6-39cd95075f4f@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Akshay,

Am 17.03.2017 um 08:39 schrieb Wolfgang Grandegger:
> Hello Akshay,
>
> Am 16.03.2017 um 23:29 schrieb Akshay Bhat:
>> Hi Wolfgang,
>>
>> On 03/16/2017 04:02 PM, Wolfgang Grandegger wrote:
>>>
>>> Looks much better now! There are message for state changes to error
>>> warning and passive. Just the following message is not correct:
>>>
>>>  (000.200824)  can0  20000004   [8]  00 40 00 00 00 00 5F 19
>>> ERRORFRAME
>>>     controller-problem{}
>>>     error-counter-tx-rx{{95}{25}}
>>>
>>> Sorry, forgot to mention... the function can_change_state() [1]
>>> should be used for that purpose, if possible. It fixes the issue
>>> above as well.
>>>
>>
>> The updated driver (the one used to create the above log) is using
>> can_change_state() function. data[1] 40 corresponds to
>> CAN_ERR_CRTL_ACTIVE, so looks correct? Could it be that the can-utils I
>> am using is old and not reporting state change?
>
> Hm, yes. The raw data looks correct. You could download and build a
> recent version from "https://github.com/linux-can/can-utils" to check.
> It could also be a bug.

Support for that flags has been added in December 2014.

Wolfgang-
