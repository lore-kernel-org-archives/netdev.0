From: Tonghao Zhang <xiangxia.m.yue@gmail.com>
Subject: Re: [PATCH v3] datapath: Avoid using stack larger than 1024.
Date: Fri, 30 Jun 2017 12:38:55 +0800
Message-ID: <CAMDZJNX3hQ2AK3WUdd9vjfyVCAPauYVV9bK4bGYh=9B53jbqyA@mail.gmail.com>
References: <1498700323-98406-1-git-send-email-xiangxia.m.yue@gmail.com> <CAOrHB_B7PpKMdVn8JNG9B-R6i80Zxn8rEBBptCSKCTz6TdsU6g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Greg Rose <gvrose8192@gmail.com>
To: Pravin Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:34869 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750730AbdF3Ei4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2017 00:38:56 -0400
Received: by mail-oi0-f68.google.com with SMTP id l130so11106016oib.2
        for <netdev@vger.kernel.org>; Thu, 29 Jun 2017 21:38:56 -0700 (PDT)
In-Reply-To: <CAOrHB_B7PpKMdVn8JNG9B-R6i80Zxn8rEBBptCSKCTz6TdsU6g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for your works. I send v3 for net-next and add "Acked-by".
If it is applied, I will backport it to dev@openvswitch.org.

On Fri, Jun 30, 2017 at 1:45 AM, Pravin Shelar <pshelar@ovn.org> wrote:
> On Wed, Jun 28, 2017 at 6:38 PM, Tonghao Zhang <xiangxia.m.yue@gmail.com> wrote:
>> When compiling OvS-master on 4.4.0-81 kernel,
>> there is a warning:
>>
>>     CC [M]  /root/ovs/datapath/linux/datapath.o
>>     /root/ovs/datapath/linux/datapath.c: In function
>>     'ovs_flow_cmd_set':
>>     /root/ovs/datapath/linux/datapath.c:1221:1: warning:
>>     the frame size of 1040 bytes is larger than 1024 bytes
>>     [-Wframe-larger-than=]
>>
>> This patch factors out match-init and action-copy to avoid
>> "Wframe-larger-than=1024" warning. Because mask is only
>> used to get actions, we new a function to save some
>> stack space.
>>
>> Signed-off-by: Tonghao Zhang <xiangxia.m.yue@gmail.com>
>> ---
> Looks good, you have to submit patch against net-next for upstream OVS
> module first.
