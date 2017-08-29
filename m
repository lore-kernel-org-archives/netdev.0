From: Ravish Kumar <ravishk2004@gmail.com>
Subject: Re: Hooking on L4 Level with process information
Date: Tue, 29 Aug 2017 09:06:37 +0530
Message-ID: <CAEDnJm+_15jKc25WqYH62PGuyfNLjcCqv5CHc0HpYdsS-U7Mfw@mail.gmail.com>
References: <CAEDnJmJZ1-4DFtjmzDO1US2HCuHYDkcsa+tk8mN3CZ6vcDLbVw@mail.gmail.com>
 <20170828201900.625a10ed@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Networking <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f50.google.com ([209.85.213.50]:33383 "EHLO
        mail-vk0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751218AbdH2Dgj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 23:36:39 -0400
Received: by mail-vk0-f50.google.com with SMTP id j7so6462267vke.0
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 20:36:38 -0700 (PDT)
In-Reply-To: <20170828201900.625a10ed@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Not convinced with this .

A process open a socket and that socket is associated with that
particular process unless it shares the file descriptors.
Can you explain why it is not related , at a time a socket will be
opened by a particular process.

On Tue, Aug 29, 2017 at 8:49 AM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Tue, 29 Aug 2017 07:34:51 +0530
> Ravish Kumar <ravishk2004@gmail.com> wrote:
>
>> Hi,
>>
>> I want to hook tcp/udp packets on L4 Layer and based on process
>> information , content want to deny or allow packets.
>>
>> Netfilter provides pre/post Routing hooks but not sure that will be
>> right place so thought of asking whether my approach is right.
>> Also how i can get process information whether this packet is send by
>> this process.
>>
>> Thoughts /source code reference would be appreciated.
>>
>> Regards,
>> Ravish
>
> There is not a 1:1 relationship between sockets/files and processes.
