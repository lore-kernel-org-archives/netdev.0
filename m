From: Sylvain Munaut <s.munaut@whatever-company.com>
Subject: Re: NULL deref in bnx2 / crashes ? ( was: netconsole leads to stalled
 CPU task )
Date: Mon, 17 Sep 2012 12:57:30 +0200
Message-ID: <CAF6-1L4VaG4JAK0kYYizMvhBcaUM5x3uatA7JpzZqzcJ+fmGww@mail.gmail.com>
References: <CAF6-1L4wh0P-Wi-keN98wb-2V_avZYVE3ycf3tEe9SBpgK1dDQ@mail.gmail.com>
	<1345634026.5158.1084.camel@edumazet-glaptop>
	<CAF6-1L6zr5WJxo6FVk+2ya=EEs++u3x9iSrDxX-weBofLJuA1g@mail.gmail.com>
	<1345640757.5158.1321.camel@edumazet-glaptop>
	<CAF6-1L5hKU-VM0E5vCwExJ4kb8YB=ndotgfH7pbpxO6Q7+JHUQ@mail.gmail.com>
	<k2q0ck$rpr$1@ger.gmane.org>
	<1347455135.13103.949.camel@edumazet-glaptop>
	<CAF6-1L6RJkV6u4Rc2uDMQGUG23EGRKrdWSzTiHEYO9Z9ioGtaw@mail.gmail.com>
	<50532FA1.3070706@gmail.com>
	<CAF6-1L42ZLSm4SMRSoz6ZwDKRpfRhwQmN3R5D7kjmjqRLn=2xg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:46981 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755611Ab2IQK5b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2012 06:57:31 -0400
Received: by vcbfo13 with SMTP id fo13so6026647vcb.19
        for <netdev@vger.kernel.org>; Mon, 17 Sep 2012 03:57:30 -0700 (PDT)
In-Reply-To: <CAF6-1L42ZLSm4SMRSoz6ZwDKRpfRhwQmN3R5D7kjmjqRLn=2xg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

>> Anyway, I think Eric is right, the bug may be in other place. I am wondering
>> if the attached patch could help? It seems in netpoll tx path, we miss the
>> chance of calling ->ndo_select_queue().
>>
>> Please give it a try.
>
> This fixes the NULL deref as well. I applied your patch over vanilla
> 3.6-rc5 (so without eric's patch) and I can load netconsole without it
> crashing directly.
>
> I will try to put a bit of load on the machine and see how it behaves,
> if it solves the hung cpu tasks as well.

So far so good, the machine is still alive and well after 3 days with
netconsole enabled.


Cheers,

    Sylvain
