From: Srihari Vijayaraghavan <sriharivijayaraghavan@yahoo.com.au>
Subject: r8169 - dac testing (was: [mini-RFT] r8169 and amd64)
Date: Thu, 21 Oct 2004 01:11:07 +0000 (UTC)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200410221112.18575.sriharivijayaraghavan@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Date: Fri, 22 Oct 2004 11:12:18 +1000
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello Francois,

I read your email with a subject "[mini-RFT] r8169 and amd64" at LKML 
(archive). Since I am not subscribed to LKML I am unable to answer to that 
thread. Sorry.

Anyway, I have applied your patch at 
http://www.fr.zoreil.com/people/francois/misc/20041020-2.6.9-r8169.c-test.patch 
to vanilla 2.6.9, and tested it on my AMD64.

In its default configuration, ie, without use_dac=1 parameter, it works great. 
But OTOH with that parameter kernel displays these messages:

eth0: Identified chip type is 'RTL8169s/8110s'.
eth0: RTL8169 at 0xffffff0000040000, 00:0d:61:15:23:e6, IRQ 18
r8169: eth0: PCI error (cmd = 0x0017, status = 0x22b0).
eth1: link up, 100Mbps, full-duplex, lpa 0x45E1

And the network card does not work, as I cannot ping another host (DSL 
modem/router) on the network.

(Once I load the module with that parameter, unloading and reloading it 
without that parameter does not bring the network card back to its working 
configuration.)

Thank you.
Hari.
