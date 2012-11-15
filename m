From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Latest 3.6.6 are not compiling due tg3 network driver,
 =?UTF-8?Q?hwmon=5Fdevice=5Funregister?=
Date: Thu, 15 Nov 2012 05:03:48 +0200
Message-ID: <8b566c4a9ee622737212dc17291ee238@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
To: Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

During compiling i am getting that:

drivers/built-in.o: In function `tg3_close':
tg3.c:(.text+0x12902e): undefined reference to 
`hwmon_device_unregister'
drivers/built-in.o: In function `tg3_hwmon_open':
tg3.c:(.text+0x12ae09): undefined reference to `hwmon_device_register'

Kernel config are at http://nuclearcat.com/config-tg3.txt  , but i 
noticed this error are appearing at x86, x64 kernels, probably also 
other 3.6.x series kernels.
Disabling TG3 driver helps, but i believe it is not a solution.

---
Denys Fedoryshchenko, Network Engineer, Virtual ISP S.A.L.
