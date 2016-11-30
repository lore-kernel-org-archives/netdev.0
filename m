From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] netns: avoid disabling irq for netns id
Date: Tue, 29 Nov 2016 22:51:08 -0800
Message-ID: <CAM_iQpVd9m=N6S3jPKuFWLJ2oQ7ze9ewzneq97D0ia7_xc1sqg@mail.gmail.com>
References: <148045748887.22539.3188295553967836703.stgit@sifl> <CAGH-KgsK=Dc=Ptfg8P39pemFAsxVr9NKccev7sOW=w1suqKk+w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        linux-audit@redhat.com
To: Paul Moore <pmoore@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:35493 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753128AbcK3Gv3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 01:51:29 -0500
Received: by mail-io0-f196.google.com with SMTP id h133so566450ioe.2
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 22:51:29 -0800 (PST)
In-Reply-To: <CAGH-KgsK=Dc=Ptfg8P39pemFAsxVr9NKccev7sOW=w1suqKk+w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 29, 2016 at 2:14 PM, Paul Moore <pmoore@redhat.com> wrote:
> On Tue, Nov 29, 2016 at 5:11 PM, Paul Moore <pmoore@redhat.com> wrote:
>> From: Paul Moore <paul@paul-moore.com>
>>
>> Bring back commit bc51dddf98c9 ("netns: avoid disabling irq for netns
>> id") now that we've fixed some audit multicast issues that caused
>> problems with original attempt.  Additional information, and history,
>> can be found in the links below:
>>
>>  * https://github.com/linux-audit/audit-kernel/issues/22
>>  * https://github.com/linux-audit/audit-kernel/issues/23
>>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>> Signed-off-by: Paul Moore <paul@paul-moore.com>
>> ---
>>  net/core/net_namespace.c |   35 +++++++++++++++--------------------
>>  1 file changed, 15 insertions(+), 20 deletions(-)
>
> Cong Wang, I added your sign-off to the patch since you were the
> original author, if you would prefer I leave it off or want it changed
> just let me know.

Thanks for not forgetting it. I am fine with signed-off-by.
