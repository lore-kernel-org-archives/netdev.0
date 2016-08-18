From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 0/3] Fix mv88e6xxx wait function
Date: Thu, 18 Aug 2016 18:22:50 -0400
Message-ID: <877fbdiuo5.fsf@ketchup.mtl.sfl>
References: <1471557717-21852-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:45289 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750953AbcHSBCw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 21:02:52 -0400
In-Reply-To: <1471557717-21852-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Lunn <andrew@lunn.ch> writes:

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
>
> Andrew Lunn (3):
>   dsa: mv88e6xxx: Timeout based on iterations, not time
>   dsa: mv88e6xxx: Use mv88e6xx_wait in mv88e6xxx_update()
>   dsa: mv88e6xxx: Make mv88e6xxx_wait() timeout verbose
>
>  drivers/net/dsa/mv88e6xxx/chip.c | 32 +++++++++++---------------------
>  1 file changed, 11 insertions(+), 21 deletions(-)

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

David, this series superseeds http://patchwork.ozlabs.org/patch/660270/.

Thanks,

        Vivien
