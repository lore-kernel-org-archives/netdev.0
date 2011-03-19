From: Andreas Schwab <schwab@linux-m68k.org>
Subject: Re: ipv6 secondary ips and default ipv6 ip for new outbound connections
Date: Sat, 19 Mar 2011 09:02:17 +0100
Message-ID: <m2k4fvbks6.fsf@igel.home>
References: <20110318230312.GX13831@surrealistic.net>
	<4D8413BE.5000305@hp.com> <20110319033507.GY13831@surrealistic.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brian Haley <brian.haley@hp.com>, netdev@vger.kernel.org
To: Jim Westfall <jwestfall@surrealistic.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:45235 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752099Ab1CSICV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Mar 2011 04:02:21 -0400
In-Reply-To: <20110319033507.GY13831@surrealistic.net> (Jim Westfall's message
	of "Fri, 18 Mar 2011 20:35:07 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jim Westfall <jwestfall@surrealistic.net> writes:

> Your patch fixes it for me.
>
> # ip addr add 2600:c00:0:1::1101/64 dev eth0
> ~# traceroute6 www.kame.net | head -0
> traceroute to orange.kame.net (2001:200:dff:fff1:216:3eff:feb1:44d7) from 2600:c00:0:1::1101, 30 hops max, 16 byte packets
>
> ~# ip addr add 2600:c00:0:1::1102/64 dev eth0
> ~# traceroute6 www.kame.net | head -0
> traceroute to orange.kame.net (2001:200:dff:fff1:216:3eff:feb1:44d7) from 2600:c00:0:1::1101, 30 hops max, 16 byte packets
>
> ~# ip addr add 2600:c00:0:1::1103/64 dev eth0
> ~# traceroute6 www.kame.net | head -0
> traceroute to orange.kame.net (2001:200:dff:fff1:216:3eff:feb1:44d7) from 2600:c00:0:1::1101, 30 hops max, 16 byte packets

Does this also affect the selected address if use_tempaddr=2?

Andreas.

-- 
Andreas Schwab, schwab@linux-m68k.org
GPG Key fingerprint = 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
