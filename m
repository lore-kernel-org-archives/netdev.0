From: Alon Nafta <alon@privatecore.com>
Subject: Re: [PATCH 1/4 V2] Ethernet drivers in 3.14-rc3 kernel: fix 3 buffer
 overflows triggered by hardware devices
Date: Mon, 24 Mar 2014 16:27:54 -0700
Message-ID: <CAKPWWNFhqP==HfQC6aV=OFs6Ud6bBDa9hpCrvih8BxDUDo87JA@mail.gmail.com>
References: <CAKPWWNFZc8v04-GM5Ttoa-CW_zhNmfMCYO2Q-Yh-75qitSUpiA@mail.gmail.com>
	<20140324.131733.723749970605014851.davem@davemloft.net>
	<CAKPWWNF982P7PtuoySy6ncU1mCNFm2RBMEDKr3-QKoCKU-6AMw@mail.gmail.com>
	<20140324.143512.68893694230434555.davem@davemloft.net>
	<1395697861.2832.84.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	David Laight <David.Laight@aculab.com>,
	netdev <netdev@vger.kernel.org>,
	Grant Grundler <grantgrundler@gmail.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:34033 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750866AbaCXX14 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 19:27:56 -0400
Received: by mail-la0-f54.google.com with SMTP id mc6so4240658lab.13
        for <netdev@vger.kernel.org>; Mon, 24 Mar 2014 16:27:54 -0700 (PDT)
In-Reply-To: <1395697861.2832.84.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I don't think they should be trusted at all, at least not to a point
where it's feasible for them to execute code on your system.
USB drivers, filesystem drivers, peripheral drivers - they're all on
the same boat, obviously having different levels of severity depending
on driver popularity.

>
> There is a real question as to how much peripherals should be trusted.
>
> We already try to avoid trusting USB devices at all, because many
> machines have ports that are accessible to users that shouldn't be fully
> trusted.  (Also, users may assume it's just as safe to plug in a 'USB
> stick' they were given, as it is to insert a disc or memory card.)  A
> bug in the HID subsystem has apparently been exploited in the past for
> code injection.
>
> Given that some machines also have easily accessible hotplug PCI(e)
> ports (CardBus, ExpressCard, Thunderbolt), and that those can be
> distrusted at the hardware level (using an IOMMU), it seems like a
> worthwhile goal to distrust them at the software level.  However, as you
> hinted, this is a big job since any vulnerable driver that's installed
> can be exploited.
>
> Ben.
>
> --
> Ben Hutchings
> Everything should be made as simple as possible, but not simpler.
>                                                            - Albert Einstein
