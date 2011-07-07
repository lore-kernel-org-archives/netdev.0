From: Alexey Zaytsev <alexey.zaytsev@gmail.com>
Subject: Re: [Bugme-new] [Bug 38102] New: BUG kmalloc-2048: Poison overwritten
Date: Thu, 7 Jul 2011 11:45:47 +0400
Message-ID: <CAB9v_DF1-q31Y57CUzinXOfGtNejoCAEJVc7u2ECWNLDj97ZPQ@mail.gmail.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?Michael_B=C3=BCsch?= <m@bues.ch>,
	Neil Horman <nhorman@tuxdriver.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, Gary Zambrano <zambrano@broadcom.com>,
	bugme-daemon@bugzilla.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Pekka Pietikainen <pp@ee.oulu.fi>,
	Florian Schirmer <jolt@tuxbox.org>,
	Felix Fietkau <nbd@openwrt.org>, Michael Buesch <mb@bu3sch.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:43481 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751993Ab1GGHps convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2011 03:45:48 -0400
Received: by vws1 with SMTP id 1so535652vws.19
        for <netdev@vger.kernel.org>; Thu, 07 Jul 2011 00:45:47 -0700 (PDT)
In-Reply-To: <1310021286.2481.36.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 7, 2011 at 10:48, Eric Dumazet <eric.dumazet@gmail.com> wro=
te:
> Le jeudi 07 juillet 2011 =C3=A0 10:32 +0400, Alexey Zaytsev a =C3=A9c=
rit :
>> Sorry, been busy for the last couple days. Any patches I should test=
?
>
> Please try :
>

Thanks. Seems to fail to initialize, getting this in dmesg:

[  103.421577] b44 0000:02:0e.0: PCI INT A -> GSI 16 (level, low) -> IR=
Q 16
[  103.440139] ssb: Core 0 found: Fast Ethernet (cc 0x806, rev 0x07,
vendor 0x4243)
[  103.440159] ssb: Core 1 found: V90 (cc 0x807, rev 0x03, vendor 0x424=
3)
[  103.440177] ssb: Core 2 found: PCI (cc 0x804, rev 0x0A, vendor 0x424=
3)
[  103.481128] ssb: Sonics Silicon Backplane found on PCI device 0000:0=
2:0e.0
[  103.481532] b44: b44.c:v2.0
[  103.502185] b44 ssb1:0: eth0: Broadcom 44xx/47xx 10/100BaseT
Ethernet 00:17:a4:dd:4e:93
[  109.405071] b44 ssb1:0: eth0: powering down PHY
[  112.816456] b44 ssb1:0: eth0: Link is up at 100 Mbps, full duplex
[  112.816470] b44 ssb1:0: eth0: Flow control is off for TX and off for=
 RX
[  112.952073] b44 ssb1:0: eth0: powering down PHY
[  113.816148] b44 ssb1:0: eth0: Link is down
[  114.953717] b44 ssb1:0: eth0: powering down PHY
[  117.816246] b44 ssb1:0: eth0: Link is up at 100 Mbps, full duplex
[  117.816260] b44 ssb1:0: eth0: Flow control is off for TX and off for=
 RX
[  117.963238] b44 ssb1:0: eth0: powering down PHY
[  118.816128] b44 ssb1:0: eth0: Link is down
[  119.962817] b44 ssb1:0: eth0: powering down PHY
