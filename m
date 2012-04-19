From: Kristian Evensen <kristian.evensen@gmail.com>
Subject: Re: RTM_NEWLINK not received by application when connecting multiple
 devices simultaneously
Date: Thu, 19 Apr 2012 17:07:59 +0200
Message-ID: <CAKfDRXjCr0aDSDT8zN8A7_iNX6KAJwrR3NxaB8GAgz5oEiCB3w@mail.gmail.com>
References: <CAKfDRXj+mydkzNFC8q2aE_JWHp3ie0cijC-itkm6sHLuZr98Fw@mail.gmail.com>
	<4F90208E.6070201@candelatech.com>
	<20120419075452.379f711b@s6510.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Greear <greearb@candelatech.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:54661 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754332Ab2DSPIA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 11:08:00 -0400
Received: by yenl12 with SMTP id l12so4491865yen.19
        for <netdev@vger.kernel.org>; Thu, 19 Apr 2012 08:07:59 -0700 (PDT)
In-Reply-To: <20120419075452.379f711b@s6510.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thank you very much for both your replies.

>>
>> Multiple netlink msgs can be received in each read of a netlink
>> socket. =A0Maybe you are only processing the first one?

Yes, my code does this. I also some debug output for the test
"nlmsg_flags & NLM_F_MULTI", but it never evaluates to true.

> I recommend using the libmnl library instead of the older
> libnetlink. The code is cleaner and it handles error cases better.
> In libmnl there is a callback interface for parsing
> netlink messages.

Thank you for the tip, I will try this as it will make my code much cle=
aner.

Btw, I hadnt paid attention the age of the package I used. However,
upgrading to the latest available in the Debian repository (20120319)
does not have an effect.

-Kristian
