From: Matteo Croce <matteo@openwrt.org>
Subject: Re: [PATCH v2] add stealth mode
Date: Tue, 14 Jul 2015 16:51:57 +0200
Message-ID: <CAFnufp1Fds_VUPARWJceu5GdLcpR1N-N3gWo6zOPwdPVdR-dEQ@mail.gmail.com>
References: <CAFnufp059tojfKYBye4eayOCvNNkAE9w_s_6E-PiG-EYp9K0Gg@mail.gmail.com>
 <21611.1436179798@turing-police.cc.vt.edu> <CAFnufp3xP3xjd8zy0uLKEGgbBAb0motLva=f1EbMJCfcKG=Y-w@mail.gmail.com>
 <559D2688.5020302@gmail.com> <CAFnufp1_JAutAm7LZsQXXPspipUy4n2C9K3Li+jsWzNpgqYBJw@mail.gmail.com>
 <55A3B73C.4090507@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Austin S Hemmelgarn <ahferroin7@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:33699 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751799AbbGNOwi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 10:52:38 -0400
In-Reply-To: <55A3B73C.4090507@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-07-13 15:03 GMT+02:00 Austin S Hemmelgarn <ahferroin7@gmail.com>:
> How about FIN/ACK and FIN/PSH/URG?

Silent:

root@debian64:~# hping3 192.168.0.2 -p 32 -FA
HPING 192.168.0.2 (eth0 192.168.0.2): AF set, 40 headers + 0 data bytes
^C
--- 192.168.0.2 hping statistic ---
3 packets transmitted, 0 packets received, 100% packet loss
round-trip min/avg/max = 0.0/0.0/0.0 ms
root@debian64:~# hping3 192.168.0.2 -p 32 -FPU
HPING 192.168.0.2 (eth0 192.168.0.2): FPU set, 40 headers + 0 data bytes
^C
--- 192.168.0.2 hping statistic ---
3 packets transmitted, 0 packets received, 100% packet loss
round-trip min/avg/max = 0.0/0.0/0.0 ms


Matteo Croce
OpenWrt Developer
  _______                     ________        __
 |       |.-----.-----.-----.|  |  |  |.----.|  |_
 |   -   ||  _  |  -__|     ||  |  |  ||   _||   _|
 |_______||   __|_____|__|__||________||__|  |____|
          |__| W I R E L E S S   F R E E D O M
 -----------------------------------------------------
 CHAOS CALMER
 -----------------------------------------------------
  * 1 1/2 oz Gin            Shake with a glassful
  * 1/4 oz Triple Sec       of broken ice and pour
  * 3/4 oz Lime Juice       unstrained into a goblet.
  * 1 1/2 oz Orange Juice
  * 1 tsp. Grenadine Syrup
 -----------------------------------------------------
