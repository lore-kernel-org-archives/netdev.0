From: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Subject: Re: mm snapshot broken-out-2007-11-20-01-45.tar.gz uploaded
Date: Tue, 20 Nov 2007 18:59:47 +0530
Message-ID: <4742E14B.1080901@linux.vnet.ibm.com>
References: <200711200953.lAK9qxjO030444@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org,
	mick@madwifi.org, linville@tuxdriver.com, netdev@vger.kernel.org,
	Andy Whitcroft <apw@shadowen.org>,
	Balbir Singh <balbir@linux.vnet.ibm.com>
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp02.in.ibm.com ([59.145.155.2]:46538 "EHLO
	e28esmtp02.in.ibm.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750941AbXKTN34 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 08:29:56 -0500
In-Reply-To: <200711200953.lAK9qxjO030444@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

The kernel build fails, with following message

  LD      drivers/net/wireless/built-in.o
drivers/net/wireless/rtl8187.o: In function `rtl8225z2_rf_init':
(.opd+0x180): multiple definition of `rtl8225z2_rf_init'
drivers/net/wireless/rtl8180.o:(.opd+0x1b0): first defined here
drivers/net/wireless/rtl8187.o: In function `rtl8225z2_rf_init':
/root/linux-2.6.24-rc3/drivers/net/wireless/rtl8187_rtl8225.c:571: multiple definition of `.rtl8225z2_rf_init'
drivers/net/wireless/rtl8180.o:/root/linux-2.6.24-rc3/drivers/net/wireless/rtl8180_rtl8225.c:561: first defined here
ld: Warning: size of symbol `.rtl8225z2_rf_init' changed from 3836 in drivers/net/wireless/rtl8180.o to 3544 in drivers/net/wireless/rtl8187.o
drivers/net/wireless/rtl8187.o: In function `rtl8225_rf_set_channel':
(.opd+0x160): multiple definition of `rtl8225_rf_set_channel'
drivers/net/wireless/rtl8180.o:(.opd+0x1d0): first defined here
drivers/net/wireless/rtl8187.o: In function `rtl8225_rf_init':
/root/linux-2.6.24-rc3/drivers/net/wireless/rtl8187_rtl8225.c:329: multiple definition of `.rtl8225_rf_init'
drivers/net/wireless/rtl8180.o:/root/linux-2.6.24-rc3/drivers/net/wireless/rtl8180_rtl8225.c:322: first defined here
ld: Warning: size of symbol `.rtl8225_rf_init' changed from 3492 in drivers/net/wireless/rtl8180.o to 3528 in drivers/net/wireless/rtl8187.o
drivers/net/wireless/rtl8187.o: In function `rtl8225_rf_stop':
(.opd+0x190): multiple definition of `rtl8225_rf_stop'
drivers/net/wireless/rtl8180.o:(.opd+0x1c0): first defined here
drivers/net/wireless/rtl8187.o: In function `rtl8225_rf_set_channel':
/root/linux-2.6.24-rc3/drivers/net/wireless/rtl8187_rtl8225.c:735: multiple definition of `.rtl8225_rf_set_channel'
drivers/net/wireless/rtl8180.o:/root/linux-2.6.24-rc3/drivers/net/wireless/rtl8180_rtl8225.c:753: first defined here
ld: Warning: size of symbol `.rtl8225_rf_set_channel' changed from 360 in drivers/net/wireless/rtl8180.o to 136 in drivers/net/wireless/rtl8187.o
drivers/net/wireless/rtl8187.o: In function `rtl8225_rf_init':
(.opd+0x170): multiple definition of `rtl8225_rf_init'
drivers/net/wireless/rtl8180.o:(.opd+0x1a0): first defined here
drivers/net/wireless/rtl8187.o: In function `rtl8225_rf_stop':
/root/linux-2.6.24-rc3/drivers/net/wireless/rtl8187_rtl8225.c:719: multiple definition of `.rtl8225_rf_stop'
drivers/net/wireless/rtl8180.o:/root/linux-2.6.24-rc3/drivers/net/wireless/rtl8180_rtl8225.c:736: first defined here
ld: Warning: size of symbol `.rtl8225_rf_stop' changed from 244 in drivers/net/wireless/rtl8180.o to 632 in drivers/net/wireless/rtl8187.o
make[3]: *** [drivers/net/wireless/built-in.o] Error 1
make[2]: *** [drivers/net/wireless] Error 2
make[1]: *** [drivers/net] Error 2
make: *** [drivers] Error 2

The patch causing this build failure, might be git-wireless.patch.
-- 
Thanks & Regards,
Kamalesh Babulal,
Linux Technology Center,
IBM, ISTL.
