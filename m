From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next V7 4/4] net/sched: Introduce act_tunnel_key
Date: Fri, 9 Sep 2016 08:42:17 -0700
Message-ID: <57D2D859.5000005@gmail.com>
References: <1473341028-29368-1-git-send-email-hadarh@mellanox.com>
 <1473341028-29368-5-git-send-email-hadarh@mellanox.com>
 <57D18EA7.7000709@gmail.com>
 <CAM_iQpVQX6qHrS7-5D0URvsXhgJgU5Ln7+e+=XOuiKGmM6nu3A@mail.gmail.com>
 <1473427149.18970.55.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Hadar Hen Zion <hadarh@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>, Jiri Benc <jbenc@redhat.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Eric Dumazet <edumazet@google.com>,
        Amir Vadai <amirva@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>, Amir Vadai <amir@vadai.me>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35159 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751014AbcIIPmg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 11:42:36 -0400
Received: by mail-pf0-f195.google.com with SMTP id n24so4180981pfb.2
        for <netdev@vger.kernel.org>; Fri, 09 Sep 2016 08:42:35 -0700 (PDT)
In-Reply-To: <1473427149.18970.55.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-09 06:19 AM, Eric Dumazet wrote:
> On Thu, 2016-09-08 at 22:30 -0700, Cong Wang wrote:
>> On Thu, Sep 8, 2016 at 9:15 AM, John Fastabend <john.fastabend@gmail.com> wrote:
>>>
>>> This should be rtnl_derefence(t->params) and drop the read_lock/unlock
>>> pair. This is always called with RTNL lock unless you have a path I'm
>>> not seeing.
>>
>> You missed the previous discussion on V6, John.
>>
>> BTW, you really should follow the whole discussion instead of
>> jumping in the middle, like what you did for my patchset.
>> I understand you are eager to comment, but please don't waste
>> others' time in this way.... Please.
> 
> But John is right, and he definitely is welcome to give his feedback
> even at V13 if he wants to.
> 
> tunnel_key_dump() is called with RTNL being held.
> 
> Take a deep breath, vacations, and come back when you are relaxed.
> 
> Thanks.
> 
> 

Also v6 discussion was around cleanup() call back I see nothing about
the dump() callbacks. And if there was it wasn't fixed so it should
be resolved.

Anyways Dave/Hadar feel free to submit a follow up patch or v8 it
doesn't much matter to me as noted in the original post.

.John
