From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel panic when using bridge
Date: Tue, 12 Apr 2011 16:49:09 +0200
Message-ID: <1302619749.3233.56.camel@edumazet-laptop>
References: <4D9E62D9.5010400@scotdoyle.com>
	 <20110408121700.0aad53fe@nehalam>	<4D9FE5BE.6060600@scotdoyle.com>
	 <20110409161908.a2aca120.shimoda.hiroaki@gmail.com>
	 <4DA39330.2030102@scotdoyle.com> <20110411183105.46e86684@nehalam>
	 <4DA3CB4B.9090506@scotdoyle.com> <1302581384.3603.14.camel@edumazet-laptop>
	 <1302582172.3603.18.camel@edumazet-laptop> <4DA3E074.5090603@scotdoyle.com>
	 <1302587490.3603.22.camel@edumazet-laptop> <4DA3F909.5020609@scotdoyle.com>
	 <1302608951.3233.33.camel@edumazet-laptop>
	 <1302613353.30934.22.camel@polaris.local>
	 <1302614145.3233.47.camel@edumazet-laptop>
	 <1302617968.30934.34.camel@polaris.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Scot Doyle <lkml@scotdoyle.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>,
	netdev@vger.kernel.org
To: Jan =?ISO-8859-1?Q?L=FCbbe?= <jluebbe@debian.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:54219 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932287Ab1DLOtN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 10:49:13 -0400
Received: by wya21 with SMTP id 21so5758414wya.19
        for <netdev@vger.kernel.org>; Tue, 12 Apr 2011 07:49:12 -0700 (PDT)
In-Reply-To: <1302617968.30934.34.camel@polaris.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 12 avril 2011 =C3=A0 16:19 +0200, Jan L=C3=BCbbe a =C3=A9crit =
:

> Your patch should catch those forged packets before more harmful thin=
gs
> can go wrong, but even before my patch, i think forged packets could
> cause trouble...

Well, this is a debugging aid and wont avoid a crash later (since we
already made an out of bounds write, generally on a stack slot)

Of course, this might be a complete shot in the dark, but a
stackprotector fault in icmp_send() really sounds like a problem in
ip_options_echo() [ or bad input data given to this function ]


Other related changes (but as old as v2.6.22) :

commit 11a03f78fbf15a866ba
([NetLabel]: core network changes)



