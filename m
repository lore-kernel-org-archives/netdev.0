From: Tyler Baker <tyler.baker@linaro.org>
Subject: re: net: fec: Ensure clocks are enabled while using mdio bus
Date: Fri, 10 Jul 2015 12:07:29 -0700
Message-ID: <CANMBJr7XML6v5_75LmD7ARMHaAJo9YBodv13jCcdN2mL7Vu0ZQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Fugang Duan <B38611@freescale.com>,
	"Kevin's boot bot" <khilman@kernel.org>,
	Olof Johansson <olof@lixom.net>,
	netdev <netdev@vger.kernel.org>, Shawn Guo <shawn.guo@linaro.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f47.google.com ([209.85.192.47]:34570 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932545AbbGJTHa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 15:07:30 -0400
Received: by qgep37 with SMTP id p37so41527601qge.1
        for <netdev@vger.kernel.org>; Fri, 10 Jul 2015 12:07:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

The kernelci.org system reported[1][2][3] new imx6 boot failures in
next-20150710. I've bisected[4] these failures to 6c3e921b18ed "net:
fec: Ensure clocks are enabled while using mdio bus". Reverting this
commit on top of next-20150710, resolves the boot failures. I have not
investigated any further, but did add the imx maintainer to the CC
list. Apologies in advanced for not replying to the original thread,
as I was not subscribed to the netdev list until now.

Any chance you can confirm this regression on your end?

Cheers,

Tyler

[1] http://kernelci.org/boot/all/job/next/kernel/next-20150710/
[2] http://storage.kernelci.org/next/next-20150710/arm-multi_v7_defconfig/lab-collabora/boot-imx6q-sabrelite.html
[3] http://storage.kernelci.org/next/next-20150710/arm-imx_v6_v7_defconfig/lab-tbaker/boot-imx6q-cm-fx6.html
[4] http://hastebin.com/uzofovupey.pas
