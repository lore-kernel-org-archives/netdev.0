From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC 0/4] pktgen patches
Date: Wed, 26 Aug 2009 08:54:33 +0200
Message-ID: <4A94DC29.4070802@gmail.com>
References: <20090826061513.755294685@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	netdev@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:45879 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756851AbZHZGy6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 02:54:58 -0400
In-Reply-To: <20090826061513.755294685@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> These are some experimental (not ready yet), patches to try and
> improve the pktgen timer code. Need some review by the hrtimer folks
> as well.
>=20
>=20

I'll try these in a couple of hours thanks.

As a followup on our other pktgen thread, if I switch my 3GHz cpu to 2G=
Hz (powersave cpufreq),
then I get litle bit better pktgen throughput from my 1Gb/s tg3 link.

So getting pktgen looping faster (spending less time in kernel time ser=
vices)
might actually slow down the trafic.

We might try to avoid any memory ops while waiting txq to become availa=
ble,
and cpu_relax()/ndelay(500)/udelay(1) as much as possible, to free bus =
bandwidth ?

