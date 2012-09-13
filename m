From: Sylvain Munaut <s.munaut@whatever-company.com>
Subject: Re: NULL deref in bnx2 / crashes ? ( was: netconsole leads to stalled
 CPU task )
Date: Thu, 13 Sep 2012 19:35:33 +0200
Message-ID: <CAF6-1L6RJkV6u4Rc2uDMQGUG23EGRKrdWSzTiHEYO9Z9ioGtaw@mail.gmail.com>
References: <CAF6-1L4wh0P-Wi-keN98wb-2V_avZYVE3ycf3tEe9SBpgK1dDQ@mail.gmail.com>
	<1345634026.5158.1084.camel@edumazet-glaptop>
	<CAF6-1L6zr5WJxo6FVk+2ya=EEs++u3x9iSrDxX-weBofLJuA1g@mail.gmail.com>
	<1345640757.5158.1321.camel@edumazet-glaptop>
	<CAF6-1L5hKU-VM0E5vCwExJ4kb8YB=ndotgfH7pbpxO6Q7+JHUQ@mail.gmail.com>
	<k2q0ck$rpr$1@ger.gmane.org>
	<1347455135.13103.949.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:50390 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750974Ab2IMRfe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 13:35:34 -0400
Received: by vbbff1 with SMTP id ff1so3760012vbb.19
        for <netdev@vger.kernel.org>; Thu, 13 Sep 2012 10:35:33 -0700 (PDT)
In-Reply-To: <1347455135.13103.949.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> Yes, but I have some worries of why it is needed.
>
> Isnt it covering a bug elsewhere ?

That may very well be.

Of the few test servers I have running the same kernel, I just found
the one with netconsole active to be "stuck".

Not frozen, but all user process are hanged up and it's spitting
message about processes and CPU being "stuck". The trace is different
in each case depending on what the process was actually doing at the
time it got stuck.

No message sent to the netconsole with the root cause and nothing was
written in the logs ...

Cheers,

    Sylvain
