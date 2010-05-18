From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: bnx2/BCM5709: why 5 interrupts on a 4 core system (2.6.33.3)
Date: Tue, 18 May 2010 16:26:01 +0200
Message-ID: <1274192761.8274.3.camel@edumazet-laptop>
References: <C27F8246C663564A84BB7AB3439772421B7814753A@IRVEXCHCCR01.corp.ad.broadcom.com>
	 <1274040928.2299.17.camel@edumazet-laptop>  <4BF056F0.8010008@ans.pl>
	 <1274042826.2299.26.camel@edumazet-laptop>  <4BF05FC2.4020804@ans.pl>
	 <1274045180.2299.38.camel@edumazet-laptop>  <4BF2A288.7040304@ans.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Chan <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Krzysztof =?UTF-8?Q?Ol=C4=99dzki?= <ole@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:51404 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751096Ab0ERO0I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 10:26:08 -0400
Received: by fxm10 with SMTP id 10so1162469fxm.19
        for <netdev@vger.kernel.org>; Tue, 18 May 2010 07:26:05 -0700 (PDT)
In-Reply-To: <4BF2A288.7040304@ans.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 18 mai 2010 =C3=A0 16:22 +0200, Krzysztof Ol=C4=99dzki a =C3=A9=
crit :

> Thank you. What happens if I set it to a lower/bigger value, than=20
> avaliable txqueues in a NIC?

lower values -> same situation than today (not all txqueues will be
used)

bigger values -> it will be capped, so its only a bit more ram
allocated.



