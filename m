From: Linda Xie <lxie@us.ibm.com>
Subject: (unknown)
Date: Sat, 27 Sep 2003 22:59:19 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF011C227E.CB3C9BAE-ON87256DAF.0015CD5F@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Linda Xie <lxie@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
Subject: 
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org





Hi,

Can anyone explain why base_addr member of net_device struct in
include/linux/netdevice.h is defined as
unsigned long, while base_addr member of ifmap struct in include/linux/if.h
is defined as unsigned short?

I have a test case where netdev->base_addr is 0x230000. When dev_ifsioc()
processes a "SIOCGIFMAP"
request, it put 0x0000 into ifr->ifr_map.base_addr instead of 0x230000.

Should base_addr member of ifmap struct be defined as unsigned long and
ifconfig command be modified accordingly?

Any thoughts?

Linda
