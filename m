From: "Mathieu Olivari" <mathieu@codeaurora.org>
Subject: RE: repository for switch hardware info
Date: Mon, 2 Mar 2015 11:05:28 -0800
Message-ID: <00a201d0551b$d982f2a0$8c88d7e0$@codeaurora.org>
References: <20150222.160345.141886361578055811.davem@davemloft.net> <CANmuVZcYEyoqDhtY+5UWakYqYa6MqO4hj2MNwE1uWH=hcUKcrA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:52548 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754168AbbCBTFa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 14:05:30 -0500
Received: from MATHIEU (qf-scl1nat.qualcomm.com [207.114.132.30])
	(using TLSv1 with cipher AES256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: mathieu@smtp.codeaurora.org)
	by smtp.codeaurora.org (Postfix) with ESMTPSA id 69142141AC9
	for <netdev@vger.kernel.org>; Mon,  2 Mar 2015 19:05:29 +0000 (UTC)
In-Reply-To: <CANmuVZcYEyoqDhtY+5UWakYqYa6MqO4hj2MNwE1uWH=hcUKcrA@mail.gmail.com>
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here is what's available publically for QCA devices.

AR8xxx/QCA8xxx (Ethernet xMII/MDIO based hardware switch widely deployed in home gateways):
- open source vendor SDK is available here: https://www.codeaurora.org/cgit/quic/qsdk/oss/lklm/qca-ssdk/ (configuration command can be found in https://www.codeaurora.org/cgit/quic/qsdk/oss/ssdk-shell/) 
- same devices (AR8xxx/QCA8xxx) are also supported by OpenWrt using a swconfig based driver: http://git.openwrt.org/?p=openwrt.git;a=tree;f=target/linux/generic/files/drivers/net/phy;h=ceb9d8c46e7ffb936e3e56dcf77a0253fa5b3468;hb=HEAD (files ar8216.c & ar8327.c)

IPQ806x (NPU we talked about during netdev01):
- code is available here: https://www.codeaurora.org/cgit/quic/qsdk/
Driver is split between oss/lklm/nss-drv, oss/lklm/nss-gmac and oss/lklm/qca-nss-ecm.

Both hardware can easily be found in home routers on the market today.

Thanks,
Mathieu

---------- Forwarded message ----------
From: David Miller <davem@davemloft.net>
Date: 2015-02-22 13:03 GMT-08:00
Subject: repository for switch hardware info
To: netdev@vger.kernel.org



There are various vendor switch SDKs (some opensource, some not),
vendor switch hardware specification documents, etc. scattered all
over the place.

I was about to start doing my own research trying to find all of this
crap, but what a complete waste of time that's going to be if other
developers embark upon the same task starting from scratch just as I
would.

Therefore I'd like people to reply to this email if they know of the
location of such resources.  Just give me the URL and I'll maintain
it all on a public web page somewhere anyone can refer to or send me
updates for.

Thanks!
