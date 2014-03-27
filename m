From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 00/14] net: remove empty MDIO bus reset functions
Date: Thu, 27 Mar 2014 10:17:02 -0700
Message-ID: <CAGVrzcYOow5R9Ymz0vE1yne9UpNtRwS8NhbPBhio_no378vQkQ@mail.gmail.com>
References: <1395882446-552-1-git-send-email-f.fainelli@gmail.com> <20140327.001934.767098814214449066.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:41213 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754873AbaC0RRm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 13:17:42 -0400
Received: by mail-pa0-f52.google.com with SMTP id rd3so3766889pab.25
        for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 10:17:42 -0700 (PDT)
In-Reply-To: <20140327.001934.767098814214449066.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-03-26 21:19 GMT-07:00 David Miller <davem@davemloft.net>:
> From: Florian Fainelli <f.fainelli@gmail.com>
> Date: Wed, 26 Mar 2014 18:07:12 -0700
>
>> This patchset removes all empty MDIO bus reset functions that we have in the
>> tree (hopefully all of them). This function is optional for the MDIO bus code in
>> drivers/net/phy/mdio_bus.c::mdiobus_register, the documentation is updated to
>> reflect that.
>>
>> Having less call sites to update will allow us to implement a generic BMCR_RESET
>> based PHY reset for MDIO buses that require to reset their PHYs before their
>> PHY detection succeeds (e.g: HiSilicon hip04 current submission) and provide it
>> as a helper.
>
> Series applied, thanks.

Did you apply it locally but did not push it to net-next.git yet? I
can see the tipc changes you just replied to, but not those patches.

Thanks!
-- 
Florian
