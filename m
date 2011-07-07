From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 38102] New: BUG kmalloc-2048: Poison
 overwritten
Date: Thu, 07 Jul 2011 11:52:11 +0200
Message-ID: <1310032331.2127.8.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1309882352.2271.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20110705164202.GD2959@hmsreliant.think-freely.org>
	 <1309884441.2271.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20110705180650.GF2959@hmsreliant.think-freely.org>
	 <1309889634.2545.2.camel@edumazet-laptop>
	 <1309890775.2545.17.camel@edumazet-laptop>
	 <1309891516.2545.23.camel@edumazet-laptop>
	 <20110705195353.GG2959@hmsreliant.think-freely.org>
	 <1309896147.2545.28.camel@edumazet-laptop>
	 <1309896940.2545.34.camel@edumazet-laptop>
	 <20110705220644.GB12118@hmsreliant.think-freely.org>
	 <20110706173243.404d8599@maggie>
	 <1309971379.2292.64.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAB9v_DFmXS7_0Sx7VgVzViMSqOTtpaqiKrBABcfARigZabr5fA@mail.gmail.com>
	 <1310021286.2481.36.camel@edumazet-laptop>
	 <CAB9v_DF1-q31Y57CUzinXOfGtNejoCAEJVc7u2ECWNLDj97ZPQ@mail.gmail.com>
	 <1310030439.2127.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAB9v_DEYbPztDMr9m0B6A-a-q1gvECzX8g=B31xUp+D1_d5fZA@mail.gmail.com>
	 <CAB9v_DEfe6XnavbDB8Jj9XmSXt4MSs6sVUD4F1C8w8wsdqJjPA@mail.gmail.com>
	 <CAB9v_DFcdEFRdW-qmjr2TWwM3jtru=R+89LpaPKJ8XG_iXT3UQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael =?ISO-8859-1?Q?B=FCsch?= <m@bues.ch>,
	Neil Horman <nhorman@tuxdriver.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, Gary Zambrano <zambrano@broadcom.com>,
	bugme-daemon@bugzilla.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Pekka Pietikainen <pp@ee.oulu.fi>,
	Florian Schirmer <jolt@tuxbox.org>,
	Felix Fietkau <nbd@openwrt.org>, Michael Buesch <mb@bu3sch.de>
To: Alexey Zaytsev <alexey.zaytsev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:47055 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752456Ab1GGJwY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2011 05:52:24 -0400
Received: by wwe5 with SMTP id 5so775659wwe.1
        for <netdev@vger.kernel.org>; Thu, 07 Jul 2011 02:52:23 -0700 (PDT)
In-Reply-To: <CAB9v_DFcdEFRdW-qmjr2TWwM3jtru=R+89LpaPKJ8XG_iXT3UQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 07 juillet 2011 =C3=A0 13:43 +0400, Alexey Zaytsev a =C3=A9cri=
t :

> Ok, I've wrongly fixed this part in the clean b44.c, and got stalls.
> Then fixed the patched one after applying the stash, and still got th=
e
> stalls.

So, filling NULL to 'should not be used slots' definitely removes the
memory corruption, but also stalls the NIC.

Driver model is completely wrong. Without full hardware specs, this wil=
l
be hard to guess appropriate fixes.



