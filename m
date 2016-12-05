From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 7/8] net: reorganize struct sock for better
 data locality
Date: Mon, 05 Dec 2016 06:30:31 -0800
Message-ID: <1480948231.18162.528.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1480792497-16607-1-git-send-email-edumazet@google.com>
         <1480792497-16607-8-git-send-email-edumazet@google.com>
         <1480941384.4694.13.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Yuchung Cheng <ycheng@google.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35763 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750951AbcLEOad (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 09:30:33 -0500
Received: by mail-pg0-f66.google.com with SMTP id p66so16618950pga.2
        for <netdev@vger.kernel.org>; Mon, 05 Dec 2016 06:30:33 -0800 (PST)
In-Reply-To: <1480941384.4694.13.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-12-05 at 13:36 +0100, Paolo Abeni wrote:
> Hi Eric,

> I cherry-picked this patch only for some UDP benchmark. Under flood with
> many concurrent flows, I see this 20% improvement and a relevant
> decrease in system load.
> 
> Nice work, thanks Eric!
> 
> Tested-by: Paolo Abeni <pabeni@redhat.com>

Excellent, thanks a lot for testing !
