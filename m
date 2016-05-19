From: David Mosberger <davidm@egauge.net>
Subject: Re: [PATCH] net: phy: Ensure the state machine is called when phy is UP
Date: Thu, 19 May 2016 11:17:54 -0600
Message-ID: <CALnQHM1BUaB6Q_45fhJVMjaPeS1CQUezmXXEv1tUhWZGj=VFpQ@mail.gmail.com>
References: <CALnQHM0edN=40GHHwRrOMkQEMsHk2haRoj21bwD2ySfYoLGVvA@mail.gmail.com>
	<CALnQHM0WbaPra2qV0ZoiS=CRy726OK+U=iBBPCFkh_4Lxs_z5A@mail.gmail.com>
	<20160519163147.GH2890@piout.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>
To: Alexandre Belloni <alexandre.belloni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:32968 "EHLO
	mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755147AbcESRRz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2016 13:17:55 -0400
Received: by mail-io0-f178.google.com with SMTP id t40so23641698ioi.0
        for <netdev@vger.kernel.org>; Thu, 19 May 2016 10:17:55 -0700 (PDT)
In-Reply-To: <20160519163147.GH2890@piout.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 19, 2016 at 10:31 AM, Alexandre Belloni
<alexandre.belloni@free-electrons.com> wrote:
> On 17/05/2016 at 17:35:30 -0600, David Mosberger wrote :
>> At 7.96 seconds, phy_start() gets called, but even though this enters
>> state PHY_UP, it does not trigger phy_state_machine() and therefore
>> doesn't trigger autonegotiation.  I'm not quite sure how this is
>> intended to be handled properly.  I believe Alexandre Belloni's patch
>> would do the trick:
>>
>>  http://www.spinics.net/lists/netdev/msg373324.html
>>
>> Or has this been fixed in some other way already?
>>
>
> I don't think it has, last time I checked, Florian was still thinking
> about it.

OK.  For what it's worth, I'm using your patch now.
It looks correct to me and works (always a bonus).

  --david
-- 
Love Linux kernel hacking?  Know Python?  We are hiring!  Contact us
at jobs@egauge.net
