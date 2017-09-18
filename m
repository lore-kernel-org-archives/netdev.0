From: Roman Yeryomin <leroi.lists@gmail.com>
Subject: Re: [PATCH net-next v2 0/7] korina: performance fixes and cleanup
Date: Mon, 18 Sep 2017 16:23:08 +0300
Message-ID: <CACiydbK3WwBmQe3C36QXL76uWeoy0XGOjfTbgvK2ZLVc-2uOrA@mail.gmail.com>
References: <20170917172353.32225-1-roman@advem.lv> <649cd233-d9b8-478b-e742-5da469df8f26@gmail.com>
 <CACiydb+Au=X4wvw_ToLOw-g=y504kby4y5NwG9czFE8Hs8vnoQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f176.google.com ([209.85.128.176]:56401 "EHLO
        mail-wr0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752377AbdIRNXK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 09:23:10 -0400
Received: by mail-wr0-f176.google.com with SMTP id r74so457120wrb.13
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 06:23:09 -0700 (PDT)
In-Reply-To: <CACiydb+Au=X4wvw_ToLOw-g=y504kby4y5NwG9czFE8Hs8vnoQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18 September 2017 at 16:02, Roman Yeryomin <leroi.lists@gmail.com> wrote:
> On 17 September 2017 at 23:09, Florian Fainelli <f.fainelli@gmail.com> wrote:
>>
>>
>> On 09/17/2017 10:23 AM, Roman Yeryomin wrote:
>>> Changes from v1:
>>> - use GRO instead of increasing ring size
>>> - use NAPI_POLL_WEIGHT instead of defining own NAPI_WEIGHT
>>> - optimize rx descriptor flags processing
>>
>> net-next is closed at the moment, but these look like reasonable
>> changes, I would just replace patch 7 with a patch that entirely drops
>> the driver specific version since that does not serve any purpose in the
>> context of an in-kernel driver.
>
> OK
>

Oh, wait, forgot we've been here already.
What about ethtool_drvinfo?
Or you mean drop all ethtool helpers?

Regards,
Roman
