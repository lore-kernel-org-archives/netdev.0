From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build warnings after merge of the net tree
Date: Fri, 20 May 2016 13:33:30 +1000
Message-ID: <20160520133330.12a1aa65@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Heinrich Schuchardt <xypron.glpk@gmx.de>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

After merging the net tree, today's linux-next build (arm
multi_v7_defconfig) produced these warnings:

drivers/net/usb/pegasus.c: In function 'read_bulk_callback':
drivers/net/usb/pegasus.c:475:1: warning: label 'goon' defined but not used [-Wunused-label]
 goon:
 ^
drivers/net/usb/pegasus.c:446:8: warning: unused variable 'pkt_len' [-Wunused-variable]
  __u16 pkt_len;
        ^
drivers/net/usb/pegasus.c:445:6: warning: unused variable 'buf' [-Wunused-variable]
  u8 *buf = urb->transfer_buffer;
      ^
drivers/net/usb/pegasus.c:443:17: warning: unused variable 'count' [-Wunused-variable]
  int rx_status, count = urb->actual_length;
                 ^

Introduced by commit

  e00be9e4d0ff ("net: pegasus: remove dead coding")



-- 
Cheers,
Stephen Rothwell
