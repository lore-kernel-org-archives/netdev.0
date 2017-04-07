From: Mike Galbraith <efault@gmx.de>
Subject: Re: [Patch net] net_sched: replace yield() with cond_resched()
Date: Fri, 07 Apr 2017 05:59:02 +0200
Message-ID: <1491537542.4348.13.camel@gmx.de>
References: <1491357139-27108-1-git-send-email-xiyou.wangcong@gmail.com>
         <1491364545.4536.90.camel@gmx.de>
         <CAM_iQpXpZjpS1ZG7hH-52jt41FzzyMZ0rss9PauaSD54XSQiXQ@mail.gmail.com>
         <1491371790.4536.151.camel@gmx.de>
         <CAM_iQpUa-w9k4EFafQCEpbmR0PANwkLieYMxGwi59373h8jHUg@mail.gmail.com>
         <1491443659.4718.57.camel@gmx.de>
         <20170406181355.7fc4353a@plumbers-lap.home.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.15]:53316 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751660AbdDGD7F (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Apr 2017 23:59:05 -0400
In-Reply-To: <20170406181355.7fc4353a@plumbers-lap.home.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-04-06 at 18:13 -0400, Stephen Hemminger wrote:

> Why not replace yield with msleep(1) which gets rid of the inversion
> issues?

That's fine, just not super efficient, if that matters.

	-Mike
