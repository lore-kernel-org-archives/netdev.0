From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [Patch net] atm: remove an unnecessary loop
Date: Sat, 14 Jan 2017 01:15:20 +0100
Message-ID: <20170114001519.GB6874@electric-eye.fr.zoreil.com>
References: <CAM_iQpX2TipBW2Pm-OHRobfZaVoV9_D8Se8u9oKryt96SZFRkA@mail.gmail.com>
 <20170113132346.GA19220@electric-eye.fr.zoreil.com>
 <CAM_iQpUCVh9y8uhZ8Hj0mcjgfMGUQDvaEvSu5Wur1oVn+EZNGQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Michal Hocko <mhocko@kernel.org>,
        Chas Williams <3chas3@gmail.com>,
        Andrey Konovalov <andreyknvl@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:42565 "EHLO
        violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750713AbdANAPY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 19:15:24 -0500
Content-Disposition: inline
In-Reply-To: <CAM_iQpUCVh9y8uhZ8Hj0mcjgfMGUQDvaEvSu5Wur1oVn+EZNGQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <xiyou.wangcong@gmail.com> :
> On Fri, Jan 13, 2017 at 5:23 AM, Francois Romieu <romieu@fr.zoreil.com> wrote:
[...]
> > alloc_skb() does not need to be in the "while" loop.
> 
> This is exactly what I describe in my changelog, don't know
> why you want to repeat it...

Because it is still hidden in a while loop. 

You turned the alloc from a two level deep "while" loop to a one level
one. I want it at zero level. alloc_skb(..., GFP_KERNEL) fails ?
So let it be done (see patch in other message).

[...]
> Please don't expect me to fix many things in one patch, let's
> fix each of them separately, agreed?

I am not convinced that several patches are needed to get the whole
picture right.

-- 
Ueimor
