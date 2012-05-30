From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Difficulties to get 1Gbps on be2net ethernet card
Date: Wed, 30 May 2012 11:56:14 +0200
Message-ID: <1338371774.2760.134.camel@edumazet-glaptop>
References: <CAL8zT=hHAc5-wGMKgumV=K9jG6tDxzej9Dffe9UYQ24gdWQRtw@mail.gmail.com>
	 <CAL8zT=jKhRjVCdYRCerMzimxPAhP5Gi+JBBfuKjG-rfg-LMoVw@mail.gmail.com>
	 <1338360536.2760.85.camel@edumazet-glaptop>
	 <CAL8zT=h2hoTWDMpTe8P-xfm-USXD6spx8fFVmm1UXyOfuuqhZw@mail.gmail.com>
	 <1338361587.2760.94.camel@edumazet-glaptop>
	 <CAL8zT=jHWhDdv-DyXL8XnL8qRc7o-jZfA7ADU-qt54hB5aLyCw@mail.gmail.com>
	 <CAL8zT=gJT1Frn_44SU0CrpZjPxwC_VuHFE4k9jvOGNmFomzhHA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Jean-Michel Hautbois <jhautbois@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:39082 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750955Ab2E3J4S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 05:56:18 -0400
Received: by bkcji2 with SMTP id ji2so3922093bkc.19
        for <netdev@vger.kernel.org>; Wed, 30 May 2012 02:56:17 -0700 (PDT)
In-Reply-To: <CAL8zT=gJT1Frn_44SU0CrpZjPxwC_VuHFE4k9jvOGNmFomzhHA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-05-30 at 11:40 +0200, Jean-Michel Hautbois wrote:

> I used vmstat in order to see the differences between the two kernels.
> The main difference is the number of interrupts per second.
> I have an average of 87500 on 3.2 and 7500 on 2.6, 10 times lower !
> I suspect the be2net driver to be the main cause, and I checkes the
> /proc/interrupts file in order to be sure.
> 
> I have for eth1-tx on 2.6.26 about 2200 interrupts per second and 23000 on 3.2.
> BTW, it is named eth1-q0 on 3.2 (and tx and rx are the same IRQ)
> whereas there is eth1-rx0 and eth1-tx on 2.6.26.
> 

Might be different coalescing params :

ethtool -c eth1
