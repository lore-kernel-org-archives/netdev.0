From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: cpu offline cause napi stall
Date: Tue, 07 Jun 2011 09:09:55 +0200
Message-ID: <1307430595.2642.81.camel@edumazet-laptop>
References: <20110601181253.GA2374@osiris.boeblingen.de.ibm.com>
	 <1306958592.3946.0.camel@edumazet-laptop>
	 <20110601204233.GA2410@osiris.boeblingen.de.ibm.com>
	 <20110606.145051.267562411413352856.davem@davemloft.net>
	 <1307429403.2642.77.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: heiko.carstens@de.ibm.com, blaschka@linux.vnet.ibm.com,
	netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:58992 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751654Ab1FGHKA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2011 03:10:00 -0400
In-Reply-To: <1307429403.2642.77.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 07 juin 2011 =C3=A0 08:50 +0200, Eric Dumazet a =C3=A9crit :
> While doing my tests on bnx2x adapter, I found patch was working ok,
> but /proc/interrupts still increment interrupt count on my offlined
> cpu... go figure...

Oh well, "cat /proc/interrupts" skips offlined cpu, of course, thats a
false alarm.

I was doing "grep eth1 /proc/interrupts" so didnt catch this.



