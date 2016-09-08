From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net_namespace: fixed net_device reference leak
Date: Thu, 08 Sep 2016 14:05:50 -0700
Message-ID: <1473368750.18970.11.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAJD3hpUgNJPOqGmAp7tEaY2+EnOasG=W6VLOMbEhDRgr8M5v8A@mail.gmail.com>
         <CAJD3hpUSqSxtgJMK__V-j8VKRwf-ftZFHw0J38VTxP9tDDZyhA@mail.gmail.com>
         <1473368413.18970.10.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Jojy Varghese <jojy.varghese@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:34559 "EHLO
        mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752396AbcIHVFw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 17:05:52 -0400
Received: by mail-pa0-f65.google.com with SMTP id gi6so2842467pac.1
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2016 14:05:52 -0700 (PDT)
In-Reply-To: <1473368413.18970.10.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-09-08 at 14:00 -0700, Eric Dumazet wrote:

> Latest real fix was :
> https://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=751eb6b6042a596b0080967c1a529a9fe98dac1d

Another interesting fix is 

https://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=a5d0dc810abf3d6b241777467ee1d6efb02575fc
