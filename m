From: "Masayuki Ohtake" <masa-korg@dsn.okisemi.com>
Subject: [MeeGo-Dev] can: How to set bitrate
Date: Mon, 18 Oct 2010 19:56:19 +0900
Message-ID: <000b01cb6eb3$1afcfd60$66f8800a__11502.7403495789$1287399411$gmane$org@maildom.okisemi.com>
Cc: <andrew.chih.howe.khor@intel.com>, "Wang, Qi" <qi.wang@intel.com>,
	"Foster, Margie" <margie.foster@intel.com>,
	"Wang, Yong Y" <yong.y.wang@intel.com>,
	"Ewe, Kok Howg" <kok.howg.ewe@intel.com>,
	"Tomoya MORINAGA" <morinaga526@dsn.okisemi.com>,
	"Intel OTC" <joel.clark@intel.com>
To: "Wolfgang Grandegger" <wg@grandegger.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Wolfram Sang" <w.sang@pengutronix.de>,
	"Christian Pellegrin" <chripell@fsfe.org>,
	"Barry Song" <2
Return-path: <netdev-owner@vger.kernel.org>
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:24826 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754394Ab0JRK40 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Oct 2010 06:56:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I want to test our Socket CAN driver(for Topcliff) on Meego1.0.

For setting bitrate, I tried to install "iproute2". But the build failed.

================================================
[root@localhost iproute2-2.6.33]# make
sh configure
TC schedulers
 ATM no
 IPT using iptables
make[1]: Entering directory `/root/iproute2-2.6.33/lib'

<omission>

ude  -o arpd arpd.c ../lib/libnetlink.a ../lib/libutil.a -ldb -lpthread
arpd.c:19:20: error: db_185.h: No such file or directory
arpd.c:42: error: expected '=', ',', ';', 'asm' or '__attribute__' before '*' token
arpd.c: In function 'do_one_request':
arpd.c:304: error: 'DBT' undeclared (first use in this function)
arpd.c:304: error: (Each undeclared identifier is reported only once
arpd.c:304: error: for each function it appears in.)
arpd.c:304: error: expected ';' before 'dbkey'
arpd.c:308: error: 'dbase' undeclared (first use in this function)
arpd.c:338: error: 'dbkey' undeclared (first use in this function)
arpd.c:341: error: 'dbdat' undeclared (first use in this function)
arpd.c: In function 'get_arp_pkt':
arpd.c:485: error: 'DBT' undeclared (first use in this function)
arpd.c:485: error: expected ';' before 'dbkey'
arpd.c:517: error: 'dbkey' undeclared (first use in this function)
arpd.c:520: error: 'dbase' undeclared (first use in this function)
arpd.c:520: error: 'dbdat' undeclared (first use in this function)
arpd.c: In function 'main':
arpd.c:670: error: 'dbase' undeclared (first use in this function)
arpd.c:670: warning: implicit declaration of function 'dbopen'
arpd.c:670: error: 'DB_HASH' undeclared (first use in this function)
arpd.c:680: error: 'DBT' undeclared (first use in this function)
arpd.c:680: error: expected ';' before 'dbkey'
arpd.c:682: error: 'dbkey' undeclared (first use in this function)
arpd.c:712: error: 'dbdat' undeclared (first use in this function)
arpd.c:728: error: expected ';' before 'dbkey'
arpd.c:730: error: 'R_NEXT' undeclared (first use in this function)
make[1]: *** [arpd] Error 1
make[1]: Leaving directory `/root/iproute2/misc'
make: *** [all] Error 2
[root@localhost iproute2]#
================================================

Do you know how to set bitrate on Meego?


Thanks, Ohtake(OKISemi)



