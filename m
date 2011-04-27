From: "Tomoya MORINAGA" <morinaga526@dsn.okisemi.com>
Subject: Question for canutils
Date: Wed, 27 Apr 2011 17:36:19 +0900
Message-ID: <02D6556ECE7A41859777EB7300D12394@hacdom.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <socketcan-core@lists.berlios.de>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <toshiharu-linux@dsn.okisemi.com>
To: "'Wolfgang Grandegger'" <wg@grandegger.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi 

I have 2 questions for canutils.

1) Build issue
I downloaded the latest canutils and libsocketcan.
   - canutils-4.0.6
   - libsocketcan-0.0.8

Firstly, I installed libsocketcan-0.0.8
Secondly, I tried to install canutils-4.0.6.
But it failed like below.

[root@localhost canutils-4.0.6]# ./configure
...snip...
checking whether lstat correctly handles trailing slash... yes
checking whether stat accepts an empty string... no
checking for socket... yes
checking for strchr... yes
checking for strtoul... yes
checking for pkg-config... /usr/bin/pkg-config
checking pkg-config is at least version 0.9.0... yes
checking for libsocketcan... no
configure: error: *** libsocketcan version above 0.0.8 not found on your system
[root@localhost canutils-4.0.6]# 

Do you have any information about the fail?

BTW, Using canutils-3.0.2, I could confirm build becomes success.

----------------------------------------------------------------------------------------------------------------------

2) How to use
Executing candump like following, I see the following message.(Of course, pch_can have already installed)
[root@localhost morinaga]# candump can0
interface = can0, family = 29, type = 3, proto = 1
read: Network is down
[root@localhost morinaga]#

Would you tell me how to active can0 interface.

----------------------------------------------------------------------------------------------------------------------

With Best Regards,
(I will be away from today- 5-May.)
-----------------------------------------
Tomoya MORINAGA
OKI SEMICONDUCTOR CO., LTD.
