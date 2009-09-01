From: =?windows-1251?Q?=C0=EB=E5=EA=F1=E0=ED=E4=F0_=C4=EE=F0=E8=F4?=
	<dorif@mail.ru>
Subject: Trouble with mdio- gpio driver.
Date: Tue, 01 Sep 2009 19:43:12 +0400
Message-ID: <E1MiVVo-00087G-00.dorif-mail-ru@f9.mail.ru>
Reply-To: =?windows-1251?Q?=C0=EB=E5=EA=F1=E0=ED=E4=F0_=C4=EE=F0=E8=F4?=
	  <dorif@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1251
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx28.mail.ru ([94.100.176.42]:34099 "EHLO mx28.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751102AbZIARml (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2009 13:42:41 -0400
Received: from f9.mail.ru (f9.mail.ru [217.69.129.68])
	by mx28.mail.ru (mPOP.Fallback_MX) with ESMTP id 358C04EC1D2
	for <netdev@vger.kernel.org>; Tue,  1 Sep 2009 19:43:34 +0400 (MSD)
Received: from mail by f9.mail.ru with local
	id 1MiVVo-00087G-00
	for netdev@vger.kernel.org; Tue, 01 Sep 2009 19:43:12 +0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello! I compiled Linux kernel 2.6.31-rc8 an get this warning:
WARNING: drivers/net/phy/mdio-gpio.o(.devexit.text+0x1c): Section mismatch
in reference from the function mdio_gpio_remove() to the function
.devinit.text:mdio_gpio_bus_deinit()
The function __devexit mdio_gpio_remove() references
a function __devinit mdio_gpio_bus_deinit().
This is often seen when error handling in the exit function

I hope it will be corrected soon and won't appear in release kernel.

