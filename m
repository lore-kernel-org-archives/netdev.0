From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] net: rtnl_register in net_ns_init need rtnl_lock
Date: Thu, 22 Sep 2016 21:02:24 +0200
Message-ID: <1474570944.3879957.734128881.5386A16F@webmail.messagingengine.com>
References: <1474542209-28409-1-git-send-email-hannes@stressinduktion.org>
 <1474549384.23058.94.camel@edumazet-glaptop3.roam.corp.google.com>
 <4c1b9aba-e6e8-babc-1bbe-aef2bc0bca53@stressinduktion.org>
 <CAM_iQpUsYLWxWvcuVzHt=Q9hRjZ1vKJHWjS6ZKWc0rjdtdOo8w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:42700 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S966007AbcIVTCZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 15:02:25 -0400
In-Reply-To: <CAM_iQpUsYLWxWvcuVzHt=Q9hRjZ1vKJHWjS6ZKWc0rjdtdOo8w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 22, 2016, at 19:20, Cong Wang wrote:
> > I don't think it is a big issue but wanted the writes to the
> > rtnl_msg_handlers array to be strictly serialized. I was working on
> > adding this to other places, too. Maybe better for net-next even?
> 
> But they are called during boot, why is it possible to have a parallel
> reader/writer at that time?

It also happens during module load time, which isn't synchronized with
rtnl_lock.

Bye,
Hannes
