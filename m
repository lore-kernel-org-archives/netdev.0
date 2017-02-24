From: Roman Mashak <mrv@mojatatu.com>
Subject: Re: [PATCH net 1/1] net sched actions: decrement module reference count after table flush.
Date: Fri, 24 Feb 2017 17:10:33 -0500
Message-ID: <85a89bdyue.fsf@mojatatu.com>
References: <1487952032-508-1-git-send-email-mrv@mojatatu.com>
        <CAM_iQpW9E8UWDCVbqDqZ7pkjh5kTEO7W_=2Qk_aRUP4HMXypRQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:33407 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751273AbdBXWKi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2017 17:10:38 -0500
Received: by mail-io0-f196.google.com with SMTP id d198so410569ioe.0
        for <netdev@vger.kernel.org>; Fri, 24 Feb 2017 14:10:37 -0800 (PST)
In-Reply-To: <CAM_iQpW9E8UWDCVbqDqZ7pkjh5kTEO7W_=2Qk_aRUP4HMXypRQ@mail.gmail.com>
        (Cong Wang's message of "Fri, 24 Feb 2017 09:58:21 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <xiyou.wangcong@gmail.com> writes:

> On Fri, Feb 24, 2017 at 8:00 AM, Roman Mashak <mrv@mojatatu.com> wrote:
>> When tc actions are loaded as a module and no actions have been installed,
>> flushing them would result in actions removed from the memory, but modules
>> reference count not being decremented, so that the modules would not be
>> unloaded.

[...]

> Fixes commit f97017cdefefdb6a0e19266024b0c6f9fd411eeb ?

Yes, exactly.

> Acked-by: Cong Wang <xiyou.wangcong@gmail.com>

-- 
Roman Mashak
