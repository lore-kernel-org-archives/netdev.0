From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 2/2] ethtool: allow for a smaller build
Date: Thu, 27 Feb 2014 09:34:33 -0800
Message-ID: <CAGVrzca_1OTCtmdPZ1+BWXmnCmY6=qj7EEV9bQtn1ZmDHODgrw@mail.gmail.com>
References: <1393464911-21593-1-git-send-email-f.fainelli@gmail.com>
 <1393464911-21593-3-git-send-email-f.fainelli@gmail.com> <063D6719AE5E284EB5DD2968C1650D6D0F6CC891@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "ben@decadent.org.uk" <ben@decadent.org.uk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:45026 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751785AbaB0RfO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 12:35:14 -0500
Received: by mail-pa0-f49.google.com with SMTP id hz1so2773702pad.22
        for <netdev@vger.kernel.org>; Thu, 27 Feb 2014 09:35:14 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6CC891@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-02-27 2:05 GMT-08:00 David Laight <David.Laight@aculab.com>:
> From: Florian Fainelli
>> Introduce a new configure script option: --enable-small which will
>> disable building the driver specific register dump objects, the savings
>> are:
> ...
>> +if !SMALL
>> +ethtool_SOURCES += \
>>                 amd8111e.c de2104x.c e100.c e1000.c et131x.c igb.c    \
>>                 fec_8xx.c ibm_emac.c ixgb.c ixgbe.c natsemi.c \
>>                 pcnet32.c realtek.c tg3.c marvell.c vioc.c    \
>>                 smsc911x.c at76c50x-usb.c sfc.c stmmac.c      \
>> -               rxclass.c sfpid.c sfpdiag.c ixgbevf.c
>> +               sfpid.c sfpdiag.c ixgbevf.c
>> +endif
>
> What about allowing a subset of the register dumps be enabled?

Sure, I can do that too, as a separate list of changes though. How
would you like to see that impelmented:

--with-drivers="amd8111e de2104x....ixgbevf"

or with individual per-driver switches:

--with-adm8111e
--with-de2104x
-- 
Florian
