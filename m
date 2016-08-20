From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] Fix mv88e6xxx wait function
Date: Fri, 19 Aug 2016 17:15:04 -0700 (PDT)
Message-ID: <20160819.171504.1032992214543012801.davem@davemloft.net>
References: <1471557717-21852-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vivien.didelot@savoirfairelinux.com
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55999 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754617AbcHTAPF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 20:15:05 -0400
In-Reply-To: <1471557717-21852-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Fri, 19 Aug 2016 00:01:54 +0200

> The mv88e6xxx wait function can be upset of the system has nots of
> other things to do and a sleep takes a lot longer than expected. Fix
> this be using a fixed number of iterations, rather than a fixed
> walkclock time.
> 
> Witht that change made, it is possible to consoliate another
> wait function.
> 
> A wait actually timing out should not happen and when it does, it
> means something serious is wrong. Make sure an error is logged,
> since not all callers will log an error.

Series applied, thanks.
