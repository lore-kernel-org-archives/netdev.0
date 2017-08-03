From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH V4 net 2/2] net: fix tcp reset packet flowlabel for ipv6
Date: Wed, 2 Aug 2017 18:33:20 -0700
Message-ID: <CAM_iQpWp+gffO_xPX9vtEm+Lv5N9i2L-zawQKCkB+9UNiksG2g@mail.gmail.com>
References: <cover.1501539150.git.shli@fb.com> <373e23f5295ee4cb725109a9e58152451a9fb4cc.1501539150.git.shli@fb.com>
 <CAM_iQpXOaP4JmGW4-AcL6JYbzKq_Co_Z4pWiSh1B1i=4MsakEQ@mail.gmail.com>
 <20170731230002.ercfotm7qhfubbbv@kernel.org> <CAM_iQpWiw6CJOr2+zvxdoCht1DRERmZfZCCZiE36_6RiumEOVA@mail.gmail.com>
 <20170801214226.gnuudx3j53s6kw25@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>, Shaohua Li <shli@fb.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Florent Fourcot <flo@fourcot.fr>
To: Shaohua Li <shli@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:35811 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751184AbdHCBdm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 21:33:42 -0400
Received: by mail-wm0-f51.google.com with SMTP id m85so3159164wma.0
        for <netdev@vger.kernel.org>; Wed, 02 Aug 2017 18:33:41 -0700 (PDT)
In-Reply-To: <20170801214226.gnuudx3j53s6kw25@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 1, 2017 at 2:42 PM, Shaohua Li <shli@kernel.org> wrote:
> Is this really better? I don't see any point. I'd use my original patch other
> than this one. that said, there are just several lines of code, brutally
> 'abstract' them into a function doesn't make the code better.

The current ip6_make_flowlabel() is already a mess, with your
change you just make it worse to read. I just want to make it suck
less.
