From: Anatoly Pugachev <mator@gsib.ru>
Subject: minor error in linux/net/core/dev.c
Date: Tue, 25 Mar 2003 18:38:34 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030325153834.GJ16269@gsib.sl.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.
I can't fix this myself, so emailing to you:
[root@p4 mator]# modprobe e100
/var/log/messages:
Mar 25 17:26:46 p4 kernel: Intel(R) PRO/100 Network Driver - version 2.2.21-k1
Mar 25 17:26:46 p4 kernel: Copyright (c) 2003 Intel Corporation
Mar 25 17:26:46 p4 kernel:
Mar 25 17:26:46 p4 kernel: e100: selftest OK.
Mar 25 17:26:49 p4 kernel: Freeing alive device f6623800, eth%%d
Mar 25 17:26:50 p4 kernel: e100: eth1: Intel(R) PRO/100 Network Connection
Mar 25 17:26:50 p4 kernel:   Hardware receive checksums enabled
Mar 25 17:26:50 p4 kernel:   cpu cycle saver enabled


notice eth%%d output, i have found "Freeing alive device" in
linux/net/core/dev.c
netdev_finish_unregister()
thanks, bye.
-- 
/mator
