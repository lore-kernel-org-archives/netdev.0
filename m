From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net_sched: do not broadcast RTM_GETTFILTER result
Date: Thu, 13 Oct 2016 09:46:09 +0200
Message-ID: <1476344769.5650.25.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1476069955.28155.292.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpWDwwo+DEi2aytoAnTHWKWeTRiMZqXfvaB7=T9eOnvR-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:34386 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752626AbcJMIlI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 04:41:08 -0400
Received: by mail-lf0-f67.google.com with SMTP id x23so5730060lfi.1
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2016 01:41:08 -0700 (PDT)
In-Reply-To: <CAM_iQpWDwwo+DEi2aytoAnTHWKWeTRiMZqXfvaB7=T9eOnvR-w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-10-12 at 09:36 -0700, Cong Wang wrote:
> On Sun, Oct 9, 2016 at 8:25 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > +       if (unicast)
> > +               return netlink_unicast(net->rtnl, skb, portid, MSG_DONTWAIT);
> 
> Nit: rtnl_unicast() is simpler.

I copied code in rtnetlink_send(), I guess we could use rtnl_unicast()
there as well.
