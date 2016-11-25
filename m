From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Large performance regression with 6in4 tunnel (sit)
Date: Thu, 24 Nov 2016 19:01:28 -0800
Message-ID: <1480042888.8455.527.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20161125120947.142c3af5@canb.auug.org.au>
         <cf2fff0a-7d41-1416-0056-3718ea50a5bd@gmx.com>
         <20161125134520.68ca0969@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eli Cooper <elicooper@gmx.com>, netdev@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:35408 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752087AbcKYDBa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 22:01:30 -0500
Received: by mail-pg0-f52.google.com with SMTP id p66so24456969pga.2
        for <netdev@vger.kernel.org>; Thu, 24 Nov 2016 19:01:30 -0800 (PST)
In-Reply-To: <20161125134520.68ca0969@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-11-25 at 13:45 +1100, Stephen Rothwell wrote:

> So turning off tso brings performance up to IPv4 levels ...

ok.

> 
> Thanks for that, it solves my immediate problem.

Since I do not have this problem at all on my hosts, it could be a buggy
ethernet driver.

Could you share what NIC card and driver you are using ?
