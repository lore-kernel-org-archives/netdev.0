From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [RFC PATCH linux 0/2] net sched actions: access to uninitialized
 data and error handling
Date: Sat, 15 Apr 2017 12:51:24 -0400
Message-ID: <08ae66eb-5629-f5d9-f951-2510f041028f@mojatatu.com>
References: <20170412142140.26649-1-w.bumiller@proxmox.com>
 <CAM_iQpUvt9G+kqHUN9keuXeQ2HEtwTgBrpb3Bkzk6nxzhvdAhA@mail.gmail.com>
 <5da86d13-0e61-8282-614e-b8ade10c75e6@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Roman Mashak <mrv@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>,
        Wolfgang Bumiller <w.bumiller@proxmox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:35688 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753827AbdDOQv1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 15 Apr 2017 12:51:27 -0400
Received: by mail-io0-f194.google.com with SMTP id d203so19290706iof.2
        for <netdev@vger.kernel.org>; Sat, 15 Apr 2017 09:51:27 -0700 (PDT)
In-Reply-To: <5da86d13-0e61-8282-614e-b8ade10c75e6@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-15 10:12 AM, Jamal Hadi Salim wrote:
> On 17-04-12 09:22 PM, Cong Wang wrote:

> Sorry - didnt get the full thread (the OP managed to post to CC
> linux kernel list but not me); trying to catch up.
>
> So the issue if i understood:
> Policer was created but failed and we the error code mistakenly
> did a hash_release?
>
> I do observe an issue if the above was to happen. I think we need
> two variables instead of one.
> Will dig through the list.


I found them. The patches look sane.

Please resend v2 (the second version of patch 2 where you moved
module check up) and add my Acked-by.
Also - please dont cross post to linux kernel list (and Cc me).

I think Roman has  slightly different use case but
he triggers a related issue your patch seems to address.

cheers,
jamal
