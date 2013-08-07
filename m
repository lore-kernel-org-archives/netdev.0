From: Kinley Dorji <kinleyd@gmail.com>
Subject: Re: Bug: alx: Atheros AR8131/AR8151/AR8152/AR8161 Ethernet driver
Date: Wed, 7 Aug 2013 12:32:22 +0600
Message-ID: <CACtZaF+aamW_0P2O1zSGLWHmichAZKb96pC4GCCVZZXJsh8Y7g@mail.gmail.com>
References: <CACtZaFJZCWigdT6_vsP9BTRSORzumu33xUtyPtpiDuNn3DQi+w@mail.gmail.com>
	<20130805225752.14e843f7@nehalam.linuxnetplumber.net>
	<CACtZaF+nTHiZ03uebya92b=UVLBXAk9jnM-=Pp3GQ6oSNv8ndA@mail.gmail.com>
	<1375785799.4457.81.camel@edumazet-glaptop>
	<1375788758.8219.13.camel@jlt4.sipsolutions.net>
	<1375790821.4457.90.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:56417 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757118Ab3HGGcX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 02:32:23 -0400
Received: by mail-wi0-f177.google.com with SMTP id hq12so1273039wib.10
        for <netdev@vger.kernel.org>; Tue, 06 Aug 2013 23:32:22 -0700 (PDT)
In-Reply-To: <1375790821.4457.90.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

@Johannes Berg: > don't really care much for the
> stats in the system I'm using this device on - and based on the driver
> I'm not sure I'd use the chip for 'serious' work anyway :)

OTOH, conky users love having the stats up, even if they aren't precise. :)

There's one other point:

Before the mainlining of the alx drivers, the default settings for
Wake-on used to be d, whereas now it seems to be pg. This startled me
a couple of times with my computer turning on unexpectedly, having
been used to the previous defaults. Just FYI.

Other than that, I would like thank you all very much for your quick
responses and I look forward to having the stats code restored to the
alx drivers.

With best regards,

Kinley

On Tue, Aug 6, 2013 at 6:07 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2013-08-06 at 13:32 +0200, Johannes Berg wrote:
>
>> I don't. There are some stats in the original code at
>> https://github.com/erikarn/alx, but I removed them because I didn't
>> really understand what was going on and don't really care much for the
>> stats in the system I'm using this device on - and based on the driver
>> I'm not sure I'd use the chip for 'serious' work anyway :)
>>
>
> OK, their code seems clean and should be copied/pasted.
>
>
>> FWIW, it had ndo_get_stats() but was updating the netdev->stats from
>> that handler and then returning them, which seemed a bit questionable.
>>
>
> Its fine, as updates of each field are atomic (unsigned long)
>
>
>
