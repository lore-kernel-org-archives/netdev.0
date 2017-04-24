From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v5 1/2] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Mon, 24 Apr 2017 18:58:33 -0400
Message-ID: <70133247-4f2f-1563-161e-9c84cb97ed4f@mojatatu.com>
References: <2ca4266f-a164-d2ad-37fa-45f7ae354eb8@mojatatu.com>
 <20170424.163033.797679814568299306.davem@davemloft.net>
 <ebfe9e52-f130-3733-9348-aac022a18748@mojatatu.com>
 <20170424.182453.1488000441860994588.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: simon.horman@netronome.com, jiri@resnulli.us,
        xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
        netdev@vger.kernel.org, tom@herbertland.com, pablo@netfilter.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34735 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S978537AbdDXW6m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 18:58:42 -0400
Received: by mail-io0-f193.google.com with SMTP id h41so51786642ioi.1
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 15:58:41 -0700 (PDT)
In-Reply-To: <20170424.182453.1488000441860994588.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-24 06:24 PM, David Miller wrote:

>
> I think we should eat the pain now and use the strict checks
> for all new features like this.
>
> I'm sorry if this makes more work for you, but this is really
> how we have to proceed moving forward.
>

There is no work for me to do in tc if i push this in without
the liberal flag i was suggesting.
This is more about the next flag change that will fail with
older kernels unless the large tc change happens
i.e future ones after this kernel patch.

cheers,
jamal
