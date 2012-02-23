From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bug 42809] New: kernel panic when receiving an ipsec packet
Date: Thu, 23 Feb 2012 21:17:23 +0100
Message-ID: <1330028243.15610.40.camel@edumazet-laptop>
References: <1329962785.15610.8.camel@edumazet-laptop>
	 <4F46430D.3060802@linuxsystems.it>
	 <1330007786.15610.26.camel@edumazet-laptop>
	 <20120223.151115.1646872434333284038.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: darkbasic@linuxsystems.it, netdev@vger.kernel.org,
	openadsl-users@lists.sourceforge.net,
	openadsl-devel@lists.sourceforge.net, 660804@bugs.debian.org,
	support@traverse.com.au, support@rocksolidelectronics.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:37360 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756012Ab2BWURb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2012 15:17:31 -0500
Received: by werb13 with SMTP id b13so1014098wer.19
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2012 12:17:30 -0800 (PST)
In-Reply-To: <20120223.151115.1646872434333284038.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 23 f=C3=A9vrier 2012 =C3=A0 15:11 -0500, David Miller a =C3=A9=
crit :
> Three instances of the same piece of code, maybe a helper function is
> appropriate at that point? :-) You might even get ambitious and add a
> big comment to that helper function explaining the situation.

I did have this idea but refrained because this kind of things is harde=
r
to backport to stable kernels.

I'll make a cleanup in net-next if you agree ?
