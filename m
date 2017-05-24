From: prashantkumar dhotre <prashantkumardhotre@gmail.com>
Subject: Re: Why max netlink msg size is limited to 16k
Date: Wed, 24 May 2017 11:28:54 +0530
Message-ID: <CA+VDgmOGqY3RE5eUSMhT9wwnn2RnKFOAabCbzX7vdZOe4QC6qA@mail.gmail.com>
References: <CA+VDgmNYc=djp6ab=n49CTpyvof8CPgHvXRst5Vnm706e-nRvQ@mail.gmail.com>
 <1492875381.6453.34.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:36132 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966242AbdEXF64 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 01:58:56 -0400
Received: by mail-qt0-f194.google.com with SMTP id j13so25090979qta.3
        for <netdev@vger.kernel.org>; Tue, 23 May 2017 22:58:56 -0700 (PDT)
In-Reply-To: <1492875381.6453.34.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks
Can I use NLM_F_MULTI netlink multipart msg flag to send large buffer ?
I could not find example of that usage in sending case .

I have a kernel module and tryng to send large buffer to user app.
If I can use that flag, will kernel take care of splitting large
buffer into small chunks and will kernel also send NLMSG_DONE type msg
at end to user app?
How should I handle in user app.
Can you point me to few example please.

On Sat, Apr 22, 2017 at 9:06 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sat, 2017-04-22 at 19:43 +0530, prashantkumar dhotre wrote:
>> I am observing that max netlink msg that my kernel module can send to
>> user app is close to 16K.
>>
>> For larger sizes, genlmsg_unicast() succeeds but my app does not receive data.
>>
>> I have tried increasing RECV buffer size in my user app but that does not help.
>>
>> Regards
>
>
> You need a kernel >= linux-4.9 to get about 32KB
>
> Why is this limited ? Please read
>
> https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git/commit/?id=d35c99ff77ecb2eb239731b799386f3b3637a31e
>
>
>
