From: Paul Moore <pmoore@redhat.com>
Subject: Re: [PATCH] netns: avoid disabling irq for netns id
Date: Wed, 30 Nov 2016 15:35:46 -0500
Message-ID: <CAGH-Kgv0UpmDdaW=z8pa1VvmrcJeaA57uMneqNEgex6Xa8NSQw@mail.gmail.com>
References: <148045748887.22539.3188295553967836703.stgit@sifl> <20161130.145822.727604546507312208.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, linux-audit@redhat.com,
        xiyou.wangcong@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f172.google.com ([209.85.161.172]:33939 "EHLO
        mail-yw0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758508AbcK3Ufs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 15:35:48 -0500
Received: by mail-yw0-f172.google.com with SMTP id t125so165337106ywc.1
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 12:35:47 -0800 (PST)
In-Reply-To: <20161130.145822.727604546507312208.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 30, 2016 at 2:58 PM, David Miller <davem@davemloft.net> wrote:
> From: Paul Moore <pmoore@redhat.com>
> Date: Tue, 29 Nov 2016 17:11:29 -0500
>
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
>
> This doesn't apply cleanly to the net-next tree, could you please
> respin?

As I mentioned in a reply to the patch posting, because this relies on
a number of patches in the audit tree I've gone ahead and merged this
patch into the audit#next branch.  Unless you have any objections,
I'll send this to Linus with the rest of the v4.10 audit patches.

-- 
paul moore
security @ redhat
