From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v1 08/15] net: sched: RCU cls_tcindex
Date: Sun, 27 Jul 2014 15:01:12 -0700
Message-ID: <53D576A8.3010904@gmail.com>
References: <20140726042439.21036.57721.stgit@nitbit.x32> <20140726042900.21036.45937.stgit@nitbit.x32> <CAM_iQpUJJ02hSkTfw328D8QW_4iuWcZode0JGpguecx5GUf5Jw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Paul McKenney <paulmck@linux.vnet.ibm.com>, brouer@redhat.com
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:40655 "EHLO
	mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751537AbaG0WB0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jul 2014 18:01:26 -0400
Received: by mail-oi0-f51.google.com with SMTP id g201so5319905oib.24
        for <netdev@vger.kernel.org>; Sun, 27 Jul 2014 15:01:25 -0700 (PDT)
In-Reply-To: <CAM_iQpUJJ02hSkTfw328D8QW_4iuWcZode0JGpguecx5GUf5Jw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/27/2014 12:15 PM, Cong Wang wrote:
> On Fri, Jul 25, 2014 at 9:29 PM, John Fastabend
> <john.fastabend@gmail.com> wrote:
>> +
>> +       if (p->perfect) {
>> +               cp->perfect = kcalloc(cp->hash, sizeof(*r), GFP_KERNEL);
>> +               memcpy(cp->perfect, p->perfect, sizeof(*r) * cp->hash);
>> +       }
>
> a) You forget to check the return value of kcalloc()
> b) You can use kmemdup()
>

Ah good catch. I'll wait a bit for more feedback then send
a v2 with the fix.

Thanks!
John

-- 
John Fastabend         Intel Corporation
