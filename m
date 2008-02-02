From: Li Zefan <lizf@cn.fujitsu.com>
Subject: linux-2.6.24 compile error in drivers/net/b44.c
Date: Sat, 02 Feb 2008 09:50:40 +0800
Message-ID: <47A3CC70.8090900@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:64273 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1760986AbYBBBvc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2008 20:51:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


drivers/net/b44.c: In function 'b44_remove_one':
drivers/net/b44.c:2231: error: implicit declaration of function 'ssb_pcihost_set_power_state'
make[2]: *** [drivers/net/b44.o] Error 1
make[1]: *** [drivers/net] Error 2

I think it is caused by:

CONFIG_SSB_PCIHOST=n
CONFIG_B44=y

