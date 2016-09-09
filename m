From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next V7 4/4] net/sched: Introduce act_tunnel_key
Date: Thu, 8 Sep 2016 22:30:40 -0700
Message-ID: <CAM_iQpVQX6qHrS7-5D0URvsXhgJgU5Ln7+e+=XOuiKGmM6nu3A@mail.gmail.com>
References: <1473341028-29368-1-git-send-email-hadarh@mellanox.com>
 <1473341028-29368-5-git-send-email-hadarh@mellanox.com> <57D18EA7.7000709@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
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
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:36166 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751146AbcIIFbB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 01:31:01 -0400
Received: by mail-oi0-f67.google.com with SMTP id s71so5249780oih.3
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2016 22:31:01 -0700 (PDT)
In-Reply-To: <57D18EA7.7000709@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 8, 2016 at 9:15 AM, John Fastabend <john.fastabend@gmail.com> wrote:
>
> This should be rtnl_derefence(t->params) and drop the read_lock/unlock
> pair. This is always called with RTNL lock unless you have a path I'm
> not seeing.

You missed the previous discussion on V6, John.

BTW, you really should follow the whole discussion instead of
jumping in the middle, like what you did for my patchset.
I understand you are eager to comment, but please don't waste
others' time in this way.... Please.
