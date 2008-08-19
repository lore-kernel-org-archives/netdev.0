From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [r8169] patch for RTL8102 (5 new MAC/PHY)
Date: Tue, 19 Aug 2008 18:48:39 +0200
Message-ID: <48AAF967.4000902@redhat.com>
References: <1f9da0830808190642yacb2aacv6517e2bb86a3706@mail.gmail.com> <1f9da0830808190645o4ecf48b1i6f4d873db3c83e39@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?=3F=3F=3F=3F=3F=3F_=3F=3F=3F=3F=3F?= <leo@yuriev.ru>,
	Francois Romieu <romieu@fr.zoreil.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:43757 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755806AbYHSQst (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Aug 2008 12:48:49 -0400
In-Reply-To: <1f9da0830808190645o4ecf48b1i6f4d873db3c83e39@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Actual difference from the current r8169.c is in detection and "magic"
> handle of the 5 new versions of RTL's MACs and corresponded PHY.
The support for RTL8102 was added 2 days ago. See Francois's git tree
in r8169-fixes branch.
http://git.kernel.org/?p=linux/kernel/git/romieu/netdev-2.6.git;a=shortlog;h=r8169-fixes

> 2) simple: by RTL8169 datasheet 'rx-missed' counter is 24-bits width,
> but not 32;
interesting :-)

> 4) workaround: RTL8102 seems (sure) not have "rx-missed" (PCI-reg
> 0x4C) counter. So we should not account dev->stats.rx_missed_errors
> like RTL8169;
It seems (according Realtek's r8101 and r8168 drivers) that not only
RTL810x class but also RTL8168 class hardware don't have rx-missed. r8168
doesn't contain anything regarding RxMissed and r8101's RxMissed stuff
is commented out.

Ivan
