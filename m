From: Jan Killius <jkillius@arcor.de>
Subject: r8169: page allocation failure
Date: Sat, 16 Oct 2004 20:04:17 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200410162004.17573.jkillius@arcor.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,
I'm getting a page allocation failure under high net load.
Here is the error:
swapper: page allocation failure. order:3, mode:0x20
[<c013131e>]
[<c0131458>]
[<c0134337>]
[<c0134eaa>]
[<c013510d>]
[<c01354cc>]
[<c01ff9b2>]
[<c0204584>]
[<e09731b8>]
[<c020d9d5>]

This problem happens while a ftp transfer. The kernel version is 2.6.9-rc4 but 
I'm using the r8169 driver and the netdev snapshot from 2.6.9-rc4-mm1.

ethtool -k:
Offload parameters for eth2:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp segmentation offload: on
-- 
        Jan
