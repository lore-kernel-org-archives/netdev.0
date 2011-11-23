From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [3.1-rc8 REGRESSION] sky2 hangs machine on turning off or suspending
Date: Wed, 23 Nov 2011 08:43:30 +0100
Message-ID: <CACna6rwDjqwypAr_03NEA=x8J_2DpL2LjgSMiQmLHHGv3AA7GA@mail.gmail.com>
References: <CACna6ryTdLcWVYgHu=_mRFga1sFivpE_DyZOY-HMmKggkWAJAw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Stephen Hemminger <shemminger@vyatta.com>,
	Network Development <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:42627 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752976Ab1KWHnb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 02:43:31 -0500
Received: by faas1 with SMTP id s1so12662faa.19
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2011 23:43:30 -0800 (PST)
In-Reply-To: <CACna6ryTdLcWVYgHu=_mRFga1sFivpE_DyZOY-HMmKggkWAJAw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 9 listopada 2011 12:46 u=C5=BCytkownik Rafa=C5=82 Mi=C5=82ecki
<zajec5@gmail.com> napisa=C5=82:
> I've Sony VAIO FW11S with:
>
> 08:00.0 Ethernet controller [0200]: Marvell Technology Group Ltd.
> 88E8055 PCI-E Gigabit Ethernet Controller [11ab:4363] (rev 13)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Subsystem: Sony Corporation Device [104d:9=
035]
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Flags: bus master, fast devsel, latency 0,=
 IRQ 47
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Memory at d0120000 (64-bit, non-prefetchab=
le) [size=3D16K]
> =C2=A0 =C2=A0 =C2=A0 =C2=A0I/O ports at 2000 [size=3D256]
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Expansion ROM at d0100000 [disabled] [size=
=3D128K]
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Capabilities: [48] Power Management versio=
n 3
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Capabilities: [50] Vital Product Data
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Capabilities: [5c] MSI: Enable+ Count=3D1/=
1 Maskable- 64bit+
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Capabilities: [e0] Express Legacy Endpoint=
, MSI 00
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Capabilities: [100] Advanced Error Reporti=
ng
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Kernel driver in use: sky2
>
> Starting with:
>
> 0bdb0bd0139f3b6afa252de1487e3ce82a494db9
> Author: stephen hemminger <shemminger@vyatta.com>
> Date: =C2=A0 Fri Sep 23 11:13:40 2011 +0000
>
> =C2=A0 =C2=A0sky2: manage irq better on single port card
>
> I can not turn off my machine. I see "The system will be halted
> immediately" on ALT+CTRL+F10 and that's all. Machine doesn't turn off=
,
> I can no use SysRq, fan goes up. On CTRL+ATL+F1 I can see info about
> sending KILL signal to all processes.
>
> Reverting this single patch fixes the problem.
>
> Some dmesg sky2 output:
> [ =C2=A0 10.001833] sky2: driver version 1.29
> [ =C2=A0 10.001873] sky2 0000:08:00.0: PCI INT A -> GSI 16 (level, lo=
w) -> IRQ 16
> [ =C2=A0 10.001886] sky2 0000:08:00.0: setting latency timer to 64
> [ =C2=A0 10.001916] sky2 0000:08:00.0: Yukon-2 EC Ultra chip revision=
 3
> [ =C2=A0 10.002022] sky2 0000:08:00.0: irq 47 for MSI/MSI-X
> [ =C2=A0 10.002515] sky2 0000:08:00.0: eth0: addr 00:1d:ba:19:9e:db
> [ =C2=A0 58.764733] sky2 0000:08:00.0: eth0: enabling interface
> [ =C2=A0638.178629] sky2 0000:08:00.0: eth0: Link is up at 100 Mbps, =
full
> duplex, flow control rx

The bug was resolved by:
sky2: fix hang in napi_disable

Stephen, two comments to you:

1) I really hoped to get some info about resolving this issue. You
could just ping me that something worth testing was posted.

2) Update your e-mail address in MAINTAINERS please.

--=20
Rafa=C5=82
