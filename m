From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net_sched: gen_estimator: account for timer
 drifts
Date: Sat, 03 Dec 2016 13:54:39 -0800
Message-ID: <1480802079.18162.421.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1480695060.18162.363.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161203.161234.605773166761239343.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35294 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750789AbcLCVyl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 16:54:41 -0500
Received: by mail-pf0-f196.google.com with SMTP id i88so5850327pfk.2
        for <netdev@vger.kernel.org>; Sat, 03 Dec 2016 13:54:40 -0800 (PST)
In-Reply-To: <20161203.161234.605773166761239343.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2016-12-03 at 16:12 -0500, David Miller wrote:

> Applied.

Thanks David.

I also have to get rid of the WRITE_ONCE() done in est_timer(), since it
does not work properly on 32bit kernels.

It will target net-next, since it is not a very serious problem.
