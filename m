From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: build failure of latest ethtool
Date: Thu, 6 Dec 2012 18:06:14 +0200
Message-ID: <50C0C276.5060809@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog111.obsmtp.com ([207.126.144.131]:57711 "HELO
	eu1sys200aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932581Ab2LFQHe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2012 11:07:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben,

FYI, building the latest ethtool git fails since sfpid.c is not present 
in the Makefile. Once I built it manually and added to the linkage line, 
ethtool  builds OK.

$ gcc -Wall -g -O2   -o ethtool ethtool.o amd8111e.o de2104x.o e100.o 
e1000.o igb.o fec_8xx.o ibm_emac.o ixgb.o ixgbe.o natsemi.o pcnet32.o 
realtek.o tg3.o marvell.o vioc.o smsc911x.o at76c50x-usb.o sfc.o 
stmmac.o rxclass.o
ethtool.o: In function `do_getmodule':
/upstream/ethtool/ethtool.c:3616: undefined reference to `sff8079_show_all'
collect2: ld returned 1 exit status
make[1]: *** [ethtool] Error 1
