From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] ipv6: fix NULL dereference in ip6_route_dev_notify()
Date: Wed, 16 Aug 2017 12:15:34 -0700
Message-ID: <1502910934.4936.142.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1502795391.4936.60.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpXjhUWPC1goetn2bwG=SPeqWcz+bZvMVWOD_2cbDcG-qw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36801 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752542AbdHPTPg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 15:15:36 -0400
Received: by mail-pg0-f66.google.com with SMTP id y129so6029035pgy.3
        for <netdev@vger.kernel.org>; Wed, 16 Aug 2017 12:15:36 -0700 (PDT)
In-Reply-To: <CAM_iQpXjhUWPC1goetn2bwG=SPeqWcz+bZvMVWOD_2cbDcG-qw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-08-16 at 11:50 -0700, Cong Wang wrote:
> On Tue, Aug 15, 2017 at 4:09 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > From: Eric Dumazet <edumazet@google.com>
> >
> > Based on a syzkaller report [1], I found that a per cpu allocation
> > failure in snmp6_alloc_dev() would then lead to NULL dereference in
> > ip6_route_dev_notify().
> >
> > It seems this is a very old bug, thus no Fixes tag in this submission.
> 
> 
> It should be introduced by my commit which introduces these
> in6_dev_put().
> 

Sorry, which commit exactly ?

I got the issue on 4.3 up to latest 4.12
