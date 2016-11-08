From: Gao Feng <fgao@ikuai8.com>
Subject: Re: [PATCH net 1/1] driver: macvlan: Destroy new macvlan port if
 macvlan_common_newlink failed.
Date: Tue, 8 Nov 2016 11:22:58 +0800
Message-ID: <CA+6hz4ofB2HX1zuhMuhC_kE62b_iy6USC8aZ5Yzp--MrLrUAMw@mail.gmail.com>
References: <1478226529-26766-1-git-send-email-fgao@ikuai8.com> <20161107.203332.1849719163992933801.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Patrick McHardy <kaber@trash.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbguseast2.qq.com ([54.204.34.130]:33051 "EHLO
        smtpbguseast2.qq.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751699AbcKHDXR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 22:23:17 -0500
Received: from mail-vk0-f51.google.com (unknown [209.85.213.51])
        by esmtp4.qq.com (ESMTP) with SMTP id 0
        for <netdev@vger.kernel.org>; Tue, 08 Nov 2016 11:23:00 +0800 (CST)
Received: by mail-vk0-f51.google.com with SMTP id x186so138475786vkd.1
        for <netdev@vger.kernel.org>; Mon, 07 Nov 2016 19:23:00 -0800 (PST)
In-Reply-To: <20161107.203332.1849719163992933801.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Tue, Nov 8, 2016 at 9:33 AM, David Miller <davem@davemloft.net> wrote:
> From: fgao@ikuai8.com
> Date: Fri,  4 Nov 2016 10:28:49 +0800
>
>> From: Gao Feng <fgao@ikuai8.com>
>>
>> When there is no existing macvlan port in lowdev, one new macvlan port
>> would be created. But it doesn't be destoried when something failed later.
>> It casues some memleak.
>>
>> Now add one flag to indicate if new macvlan port is created.
>>
>> Signed-off-by: Gao Feng <fgao@ikuai8.com>
>
> You need to be more patient, it sometimes take several days before
> your get patch reviewed or applied.  Sometimes nobody reviews a change
> for some time because it is obscure or everyone is busy.

Sorry, it is my fault.
I thought this patch may be lost because there are too many emails every day.
So ping just as a reminder.

>
> All patches are tracked in patchwork, so it is never an issue of a
> change getting "lost".  Therefore, it never makes sense to ping the
> list again and ask if a change is "ok".
>
> Personally, when people ping like that, it makes me want to review
> that patch _less_ not more.  So please do not do it.
>
> Thank you.
>

Now I get it. I violated some rules as a fresh man in kernel community.
Sorry again.


Best Regards
Feng
