From: Daniele Venzano <webvenza@libero.it>
Subject: [PATCH 0/5] sis900 printk and stack usage audit
Date: Wed, 8 Dec 2004 11:47:21 +0100
Message-ID: <20041208104721.GA31707@picchio.gall.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: NetDev <netdev@oss.sgi.com>, Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patchset brings the debug output of the sis900 driver up to date,
making it actually useful.
There is also a rework of the code to avoid unnede calls to
sis630_set_eq and to remove repeated calls to pci_read_config_byte.

All the patches are made against latest netdev-2.6 tree (linus' sis900
+ altimata PHY patch)

I've tested all patches and the runtime debug parameter and everything
works as expected.

As usual all patches are available from
http://teg.homeunix.org/sis900.html

Thanks.

-- 
-----------------------------
Daniele Venzano
Web: http://teg.homeunix.org
