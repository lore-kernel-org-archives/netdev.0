From: Gao Feng <fgao@ikuai8.com>
Subject: Re: [PATCH net 1/1] net: sock: Use double send/recv buff value to
 compare with max value
Date: Thu, 9 Feb 2017 17:08:57 +0800
Message-ID: <CA+6hz4q+S5_LyVMp9OSD24U=REymv+ciur9ZaT9wH0mhSvo_cw@mail.gmail.com>
References: <1486559235-13633-1-git-send-email-fgao@ikuai8.com> <1486569601.7793.83.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbgbr2.qq.com ([54.207.22.56]:53817 "EHLO smtpbgbr2.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751893AbdBIJKi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Feb 2017 04:10:38 -0500
Received: from mail-ua0-f177.google.com (unknown [209.85.217.177])
        by esmtp4.qq.com (ESMTP) with SMTP id 0
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 17:08:58 +0800 (CST)
Received: by mail-ua0-f177.google.com with SMTP id y9so130105664uae.2
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 01:08:59 -0800 (PST)
In-Reply-To: <1486569601.7793.83.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 9, 2017 at 12:00 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2017-02-08 at 21:07 +0800, fgao@ikuai8.com wrote:
>> From: Gao Feng <fgao@ikuai8.com>
>>
>> Because the value of SO_SNDBUF and SO_RCVBUF is doubled before
>> assignment, so the real value of send and recv buffer could be more
>> than the max sysctl config sysctl_wmem_max and sysctl_rmem_max.
>>
>> Now use doulbe send/recv buffer value to compare with sysctl_wmem_max
>> and sysctl_rmem_max, and it keeps consistence with SOCK_MIN_SNDBUF
>> and SOCK_MIN_RCVBUF.
>>
>> Signed-off-by: Gao Feng <fgao@ikuai8.com>
>> ---
>
> Looks completely bogus, based on your comprehension of this code.

It is a config param, user could config any value.
So why give it one bogus?
If need more, user could config it by himself.

>
> If you need to, fix the doc, not this code.

The current codes mean the buffer could exceed the sysctl max value.
It seems inconsistent.

Regards
Feng

>
> Unless you give more details of course, why we should take your patch.
>
>
>
>
