From: Burton Windle <bwindle@fint.org>
Subject: [RFC] Silencing needless printk in socket.c
Date: Wed, 1 Oct 2003 14:41:09 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0310011429190.1125@morpheus>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Would anyone object to a patch that wraps the printk in
linux/net/socket.c:1897 in a 'if debug'?

This first appeared around 2.6.0-test5; the output may be helpful to a
developer, but I don't think it is needed in the normal dmesg.

dual266:/home/kernel/linux/net# dmesg  | grep NET
NET: Registered protocol family 16
NET: Registered protocol family 2
NET: Registered protocol family 1
NET: Registered protocol family 17


--
Burton Windle                           burton@fint.org
Linux: the "grim reaper of innocent orphaned children."
          from /usr/src/linux-2.4.18/init/main.c:461
