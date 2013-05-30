From: Richard Genoud <richard.genoud@gmail.com>
Subject: Re: [PATCHv3 RESEND 0/6] ARM: sunxi: Add support for A10 Ethernet controller
Date: Thu, 30 May 2013 19:50:24 +0200
Message-ID: <CACQ1gAhu0P0BvfNkhsSgdzeU7Pf+CxesVJ87ok2FMpfBmaRMXA@mail.gmail.com>
References: <1369387394-9453-1-git-send-email-maxime.ripard@free-electrons.com>
 <CACQ1gAgp6o8HqQcv=4cWoAZze3wtXHMX+g+7KvV-pnC2W5=iyg@mail.gmail.com> <20130530081129.GF9799@lukather>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: davem@davemloft.net, Emilio Lopez <emilio@elopez.com.ar>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kevin@allwinnertech.com, sunny@allwinnertech.com,
	shuge@allwinnertech.com, Stefan Roese <sr@denx.de>,
	Florian Fainelli <florian@openwrt.org>,
	linux-arm-kernel@lists.infradead.org
To: Maxime Ripard <maxime.ripard@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:46089 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966031Ab3E3Rup (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 13:50:45 -0400
In-Reply-To: <20130530081129.GF9799@lukather>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/5/30 Maxime Ripard <maxime.ripard@free-electrons.com>:
>
> Did you look at the load while iperf was running? I guess we can expect
> it to be pretty high since it runs without DMA.

I just did the test.
cpu is at 55%-60%

root@debian:~# date ; iperf -c 192.168.1.10 -t 300 ; cat /proc/loadavg
Thu May 30 17:43:13 UTC 2013
------------------------------------------------------------
Client connecting to 192.168.1.10, TCP port 5001
TCP window size: 20.0 KByte (default)
------------------------------------------------------------
[  3] local 192.168.1.235 port 45459 connected with 192.168.1.10 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-300.0 sec  3.28 GBytes  94.0 Mbits/sec
0.83 0.71 0.43 1/46 1770

loadavg over a 5min at 0.71, yeah, that's pretty high...

Richard.
