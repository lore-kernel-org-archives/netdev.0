From: Pavel Roskin <proski@gnu.org>
Subject: linux/802_11.h header
Date: Tue, 30 Mar 2004 15:28:58 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0403301514080.7498@marabou.research.att.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jean Tourrilhes <jt@hpl.hp.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

I see that include/linux/802_11.h in Linux 2.6.5-rc2-bk9 is included by
only one file, namely drivers/net/wireless/atmel_cs.c.  In fact,
atmel_cs.c doesn't need it (tested by compiling it).

The 802_11.h header contains some definitions already present in
drivers/net/wireless/ieee802_11.h, which is used by some drivers.  For
instance, frame subtypes are listed in both.

802_11.h also has useful definitions that should be elsewhere, such as
ieee_802_3_header and ieee_802_11_802_2_header.  I was tempted to use some
definitions from 802_11.h, but then realized that it may be deprecated if
nobody is using it.

Does anybody know who wrote 802_11.h, whether it's deprecated, and if not,
why it's not used?

-- 
Regards,
Pavel Roskin
