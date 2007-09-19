From: Joe Perches <joe@perches.com>
Subject: net-2.6.24 - build failure
Date: Wed, 19 Sep 2007 14:53:22 -0700
Message-ID: <1190238802.26101.24.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:2327 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751658AbXISVxZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2007 17:53:25 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

allyesconfig

  CC      drivers/net/wireless/p54pci.o
  LD      drivers/net/wireless/built-in.o
drivers/net/wireless/b43legacy/built-in.o: In function `tsf_read_file':
drivers/net/wireless/b43legacy/debugfs.c:80: multiple definition of `tsf_read_file'
drivers/net/wireless/b43/built-in.o:net-2.6.24/drivers/net/wireless/b43/debugfs.c:80: first defined here
drivers/net/wireless/b43legacy/built-in.o: In function `ucode_regs_read_file':
net-2.6.24/drivers/net/wireless/b43legacy/debugfs.c:106: multiple definition of `ucode_regs_read_file'
drivers/net/wireless/b43/built-in.o:net-2.6.24/drivers/net/wireless/b43/debugfs.c:106: first defined here
drivers/net/wireless/b43legacy/built-in.o: In function `restart_write_file':
net-2.6.24/drivers/net/wireless/b43legacy/debugfs.c:187: multiple definition of `restart_write_file'
drivers/net/wireless/b43/built-in.o:net-2.6.24/drivers/net/wireless/b43/debugfs.c:266: first defined here
drivers/net/wireless/b43legacy/built-in.o: In function `tsf_write_file':
net-2.6.24/drivers/net/wireless/b43legacy/debugfs.c:94: multiple definition of `tsf_write_file'
drivers/net/wireless/b43/built-in.o:net-2.6.24/drivers/net/wireless/b43/debugfs.c:94: first defined here
drivers/net/wireless/b43legacy/built-in.o: In function `txstat_read_file':
net-2.6.24/drivers/net/wireless/b43legacy/debugfs.c:139: multiple definition of `txstat_read_file'
drivers/net/wireless/b43/built-in.o:net-2.6.24/drivers/net/wireless/b43/debugfs.c:139: first defined here
drivers/net/wireless/b43legacy/built-in.o: In function `ssb_write32':
net-2.6.24/include/linux/ssb/ssb.h:385: multiple definition of `rootdir'
drivers/net/wireless/b43/built-in.o:net-2.6.24/include/linux/ssb/ssb.h:385: first defined here
drivers/net/wireless/b43legacy/built-in.o: In function `shm_read_file':
net-2.6.24/drivers/net/wireless/b43legacy/debugfs.c:120: multiple definition of `shm_read_file'
drivers/net/wireless/b43/built-in.o:net-2.6.24/drivers/net/wireless/b43/debugfs.c:120: first defined here
make[3]: *** [drivers/net/wireless/built-in.o] Error 1
make[2]: *** [drivers/net/wireless] Error 2
make[1]: *** [drivers/net] Error 2
make: *** [drivers] Error 2


