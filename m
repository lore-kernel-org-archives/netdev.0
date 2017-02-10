From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC v2 1/8] xdp: Infrastructure to generalize XDP
Date: Fri, 10 Feb 2017 10:12:08 -0500 (EST)
Message-ID: <20170210.101208.1693704737584245625.davem@davemloft.net>
References: <CALx6S37_GOP4a0x2aVbde1ynZRxDXx3A+YfY6sMMEZQEKN_1+g@mail.gmail.com>
        <20170209.223348.2143869696524078186.davem@davemloft.net>
        <CALx6S3695kv=Rr9V48k_CByCGvXLKzoM2XgpHiysB+cpaA4tzg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42114 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751858AbdBJRGu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 12:06:50 -0500
In-Reply-To: <CALx6S3695kv=Rr9V48k_CByCGvXLKzoM2XgpHiysB+cpaA4tzg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Thu, 9 Feb 2017 20:55:34 -0800

> On Thu, Feb 9, 2017 at 7:33 PM, David Miller <davem@davemloft.net> wrote:
>> From: Tom Herbert <tom@herbertland.com>
>> Date: Thu, 9 Feb 2017 18:29:54 -0800
>>
>>> So we have thousands or LOC coming into drivers every day anyway with
>>> all those properties anyway, so this "restricted" environment solves
>>> at best 1% of the problem.
>>
>> What you must understand is that no matter what someone outside of
>> upstream writes into an eBPF program, it's safe, and we can absolutely
>> prove this with the verifier and the invariants of the execution
>> environment.
>>
> This is the exact same argument the userspace stack proponents will
> use-- put your stack in userspace and you can't crash the host.

Sounds like we can therefore meet that requirement and keep them in
the kernel networking path, which supports all of our values and goals
precisely.
