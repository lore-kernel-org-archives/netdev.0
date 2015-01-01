From: Sedat Dilek <sedat.dilek@gmail.com>
Subject: Re: [PATCH net-next 0/7] Fixing the "Time Counter fixes and improvements"
Date: Thu, 1 Jan 2015 17:30:58 +0100
Message-ID: <CA+icZUXF6-_W6=YsajP4W84F5yvKCNtA3EYxKBgNS=aY4qAYPg@mail.gmail.com>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:50001 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750733AbbAAQgX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jan 2015 11:36:23 -0500
Received: by mail-wg0-f43.google.com with SMTP id k14so5457445wgh.16
        for <netdev@vger.kernel.org>; Thu, 01 Jan 2015 08:36:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Richard wrote:

Dave,

I did not catch the missing includes in my x86 and arm testing,
because those archs somehow do include clocksource.h for the drivers
in question. Sorry.

This is how I would like to fix the header fallout. We really should
decouple the timecounter/cyclecounter code from the clocksource code
where possible.


Thanks,
Richard


Richard Cochran (7):
  timecounter: provide a macro to initialize the cyclecounter mask
    field.
  bnx2x: convert to CYCLECOUNTER_MASK macro.
  e1000e: convert to CYCLECOUNTER_MASK macro.
  igb: convert to CYCLECOUNTER_MASK macro.
  ixgbe: convert to CYCLECOUNTER_MASK macro.
  mlx4: include clocksource.h again
  microblaze: include the new timecounter header.

[...]

With this conversion those 2 commits in net-next.git#master are obsolete now...

e1000e: Include clocksource.h to get CLOCKSOURCE_MASK.
igb_ptp: Include clocksource.h to get CLOCKSOURCE_MASK.


- Sedat -
