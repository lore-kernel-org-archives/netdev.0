From: Frank Li <lznuaa@gmail.com>
Subject: Re: [PATCH 4/4] FEC: Add time stamping code and a PTP hardware clock
Date: Tue, 6 Nov 2012 09:36:39 +0800
Message-ID: <CAHrpEqQsOj-m6QGr6URhOQfkdUxL8jkZUnA0ssZG3jG6zRvZjg@mail.gmail.com>
References: <1351657531-25989-1-git-send-email-Frank.Li@freescale.com>
	<20121102091902.GA3437@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Frank Li <Frank.Li@freescale.com>, lznuaa@gmail.com,
	shawn.guo@linaro.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, davem@davemloft.net
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:48386 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932372Ab2KFBgk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2012 20:36:40 -0500
Received: by mail-ie0-f174.google.com with SMTP id k13so9033449iea.19
        for <netdev@vger.kernel.org>; Mon, 05 Nov 2012 17:36:40 -0800 (PST)
In-Reply-To: <20121102091902.GA3437@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> +       Say Y here if you want to use PTP Hardware Clock (PHC) in the
>> +       driver.  Only the basic clock operations have been implemented.
>> +
>
> Does the PTP function work with every FEC on ColdFire and i.MX?

No, I just test i.MX.

>
> Or do you need to limit this option in some way?

Okay, I will do that at new patch because this patch have been accepted.

>
> You can reduce the time that the spin lock is held by moving the next
> four lines before the locked region:
>
>> +     fep->cc.mult = FEC_CC_MULT;
>> +     diff = fep->cc.mult;
>> +     diff *= ppb;
>> +     diff = div_u64(diff, 1000000000ULL);
>

Okay, I will do that at new patch and fix a bug when two boards
directly connect at 1G mode.
