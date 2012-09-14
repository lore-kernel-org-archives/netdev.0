From: Sylvain Munaut <s.munaut@whatever-company.com>
Subject: Re: NULL deref in bnx2 / crashes ? ( was: netconsole leads to stalled
 CPU task )
Date: Fri, 14 Sep 2012 17:36:55 +0200
Message-ID: <CAF6-1L42ZLSm4SMRSoz6ZwDKRpfRhwQmN3R5D7kjmjqRLn=2xg@mail.gmail.com>
References: <CAF6-1L4wh0P-Wi-keN98wb-2V_avZYVE3ycf3tEe9SBpgK1dDQ@mail.gmail.com>
	<1345634026.5158.1084.camel@edumazet-glaptop>
	<CAF6-1L6zr5WJxo6FVk+2ya=EEs++u3x9iSrDxX-weBofLJuA1g@mail.gmail.com>
	<1345640757.5158.1321.camel@edumazet-glaptop>
	<CAF6-1L5hKU-VM0E5vCwExJ4kb8YB=ndotgfH7pbpxO6Q7+JHUQ@mail.gmail.com>
	<k2q0ck$rpr$1@ger.gmane.org>
	<1347455135.13103.949.camel@edumazet-glaptop>
	<CAF6-1L6RJkV6u4Rc2uDMQGUG23EGRKrdWSzTiHEYO9Z9ioGtaw@mail.gmail.com>
	<50532FA1.3070706@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:63752 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757330Ab2INPg4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2012 11:36:56 -0400
Received: by vbbff1 with SMTP id ff1so625929vbb.19
        for <netdev@vger.kernel.org>; Fri, 14 Sep 2012 08:36:55 -0700 (PDT)
In-Reply-To: <50532FA1.3070706@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> Anyway, I think Eric is right, the bug may be in other place. I am wondering
> if the attached patch could help? It seems in netpoll tx path, we miss the
> chance of calling ->ndo_select_queue().
>
> Please give it a try.

This fixes the NULL deref as well. I applied your patch over vanilla
3.6-rc5 (so without eric's patch) and I can load netconsole without it
crashing directly.

I will try to put a bit of load on the machine and see how it behaves,
if it solves the hung cpu tasks as well.

Cheers,

    Sylvain
