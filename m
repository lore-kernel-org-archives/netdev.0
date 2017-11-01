From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Oops with HTB on net-next
Date: Wed, 1 Nov 2017 09:04:31 -0700
Message-ID: <CAM_iQpWm2oKDLj3FDESWU3kyM==kCAbznc8oHhymOGL883W3rA@mail.gmail.com>
References: <CAA93jw6y3-uO2uXJqiWeu0YeKZCuMyXCO9zvoWXBs=Z04-=KbQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:50364 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751853AbdKAQEx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 12:04:53 -0400
Received: by mail-pf0-f175.google.com with SMTP id b6so2293058pfh.7
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 09:04:52 -0700 (PDT)
In-Reply-To: <CAA93jw6y3-uO2uXJqiWeu0YeKZCuMyXCO9zvoWXBs=Z04-=KbQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 31, 2017 at 11:42 PM, Dave Taht <dave.taht@gmail.com> wrote:
> I am using a fairly complex htb + three tiers of fq_codel and a couple
> tc filters (it's the sqm-scripts "simple.qos" model). I rebased on
> net-next head an hour ago, and....
>
> [    8.357963] IPv6: ADDRCONF(NETDEV_CHANGE): enp2s0: link becomes ready
> [    9.759942] u32 classifier
> [    9.759944]     Actions configured
> [    9.762152] Mirror/redirect action on
> [    9.859138] BUG: unable to handle kernel NULL pointer dereference
> at 0000000000000018
> [    9.859149] IP: tcf_block_put+0xf/0x50

Do you have this fix?

commit 822e86d997e4d8f942818ea6ac1711f59a66ebef
Author: Cong Wang <xiyou.wangcong@gmail.com>
Date:   Mon Oct 30 11:10:09 2017 -0700

    net_sched: remove tcf_block_put_deferred()
