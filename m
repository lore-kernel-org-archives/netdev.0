From: Dmitry Novikov <dimetrios@gmail.com>
Subject: Re: [Bug 32772] New: PROBLEM: kernel BUG at net/ipv4/inetpeer.c:386
Date: Thu, 14 Apr 2011 16:02:21 +0300
Message-ID: <BANLkTi=A59zBTwrf2TsVbSrouxBhLsrH3w@mail.gmail.com>
References: <BANLkTinhnPR6fHRQD-vvbxX1n+Zxr=HTZw@mail.gmail.com>
	<20110406.111649.193697123.davem@davemloft.net>
	<BANLkTi=PTqcYd1wO_QzQTtg_PWEq2fAJMg@mail.gmail.com>
	<20110413.132403.179942105.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: eric.dumazet@gmail.com, shemminger@linux-foundation.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:45773 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754415Ab1DNNCW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2011 09:02:22 -0400
Received: by wya21 with SMTP id 21so1366683wya.19
        for <netdev@vger.kernel.org>; Thu, 14 Apr 2011 06:02:21 -0700 (PDT)
In-Reply-To: <20110413.132403.179942105.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks. Patch applied . Will wait results

2011/4/13 David Miller <davem@davemloft.net>:
> From: Dmitry Novikov <dimetrios@gmail.com>
> Date: Wed, 13 Apr 2011 23:14:03 +0300
>
>> Crash again after 7 days of uptime. slub_nomerge is set
>
> Looks like too deep stack, try this patch which is in net-2.6:
>
> --------------------
> inetpeer: reduce stack usage
>
> On 64bit arches, we use 752 bytes of stack when cleanup_once() is called
> from inet_getpeer().
>
