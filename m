From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RFC Patch net-next 1/4] net_sched: switch filter list to list_head
Date: Thu, 9 Jan 2014 20:10:32 -0800
Message-ID: <CAM_iQpVtGPWeSi83ct3SM0jdH_BY8Fursm7T7ixRD24haHz6cg@mail.gmail.com>
References: <1389291593-2494-1-git-send-email-xiyou.wangcong@gmail.com>
	<1389291593-2494-2-git-send-email-xiyou.wangcong@gmail.com>
	<52CF6D8F.60508@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f49.google.com ([209.85.219.49]:46928 "EHLO
	mail-oa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750947AbaAJEKc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 23:10:32 -0500
Received: by mail-oa0-f49.google.com with SMTP id n16so4412476oag.36
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 20:10:32 -0800 (PST)
In-Reply-To: <52CF6D8F.60508@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 9, 2014 at 7:48 PM, John Fastabend <john.fastabend@gmail.com> wrote:
<...>
>
> OK now I'm just repeating myself. You see the trend.
>
> Additionally I don't see how any of the cls_*c change routines work in
> your series. For example look at basic_change. Even with the rtnl lock
> you need to do a read, copy, update (RCU namesake) you can't just modify
> it in place like you have done.
>
> I'll send a fixed up series out in a few minutes it should illustrate
> my point.
>

Thanks for the detailed review, since it is RFC, I myself even
don't expect it is complete, see my two open questions in
cover letter.

It is already late for this merge window, so I target this for
the _next_ net-next.

Therefore, I prefer to get early reviews rather than detailed one
at this stage.
