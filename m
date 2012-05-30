From: Jean-Michel Hautbois <jhautbois@gmail.com>
Subject: Re: Difficulties to get 1Gbps on be2net ethernet card
Date: Wed, 30 May 2012 12:06:28 +0200
Message-ID: <CAL8zT=i9oLEfxuHEG2Dxm6FyHadaoz0HcCvG_zm++QcOxer_LA@mail.gmail.com>
References: <CAL8zT=hHAc5-wGMKgumV=K9jG6tDxzej9Dffe9UYQ24gdWQRtw@mail.gmail.com>
 <CAL8zT=jKhRjVCdYRCerMzimxPAhP5Gi+JBBfuKjG-rfg-LMoVw@mail.gmail.com>
 <1338360536.2760.85.camel@edumazet-glaptop> <CAL8zT=h2hoTWDMpTe8P-xfm-USXD6spx8fFVmm1UXyOfuuqhZw@mail.gmail.com>
 <1338361587.2760.94.camel@edumazet-glaptop> <CAL8zT=jHWhDdv-DyXL8XnL8qRc7o-jZfA7ADU-qt54hB5aLyCw@mail.gmail.com>
 <CAL8zT=gJT1Frn_44SU0CrpZjPxwC_VuHFE4k9jvOGNmFomzhHA@mail.gmail.com> <1338371774.2760.134.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:38086 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751161Ab2E3KGt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 06:06:49 -0400
Received: by wgbdr13 with SMTP id dr13so4847420wgb.1
        for <netdev@vger.kernel.org>; Wed, 30 May 2012 03:06:48 -0700 (PDT)
In-Reply-To: <1338371774.2760.134.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/5/30 Eric Dumazet <eric.dumazet@gmail.com>:
> On Wed, 2012-05-30 at 11:40 +0200, Jean-Michel Hautbois wrote:
>
>> I used vmstat in order to see the differences between the two kernels.
>> The main difference is the number of interrupts per second.
>> I have an average of 87500 on 3.2 and 7500 on 2.6, 10 times lower !
>> I suspect the be2net driver to be the main cause, and I checkes the
>> /proc/interrupts file in order to be sure.
>>
>> I have for eth1-tx on 2.6.26 about 2200 interrupts per second and 23000 on 3.2.
>> BTW, it is named eth1-q0 on 3.2 (and tx and rx are the same IRQ)
>> whereas there is eth1-rx0 and eth1-tx on 2.6.26.
>>
>
> Might be different coalescing params :
>
> ethtool -c eth1
>

Yes, as stated in my first e-mail, this is different, in 2.6.26 the
adaptive-tx coalescing is off, while it is on for 3.4 (sorry, I said
3.2 before but it is 3.4).
But I can't change this setting since commit 10ef9ab...
JM
