From: Carl-Daniel Hailfinger <c-d.hailfinger.kernel.2003@gmx.net>
Subject: forcedeth: version 0.17 available
Date: Mon, 17 Nov 2003 00:26:27 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FB807A3.8010207@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Andrew Morton <akpm@digeo.com>,
        Bernhard Rosenkraenzer <bero@arklinux.org>,
        Andrew de Quincey <adq@lidskialf.net>,
        Manfred Spraul <manfred@colorfullife.com>,
        Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello all,

version 0.17 of forcedeth for Linux 2.4 and 2.6 is available at
http://www.hailfinger.org/carldani/linux/patches/forcedeth/

Fixes in this release over 0.14:
*  0.15: 08 Nov 2003: fix smp deadlock with set_multicast_list
*                     during open.
*  0.16: 15 Nov 2003: include file cleanup for ppc64, rx buffer
*                     size increased to 1628 bytes.
*  0.17: 16 Nov 2003: undo rx buffer size increase. Substract 1
*                     from the tx length.

Known issues:
*  Oops during module removal, probably sysfs related. Could a
   sysfs expert please take a look at the code? Call trace is at
   http://www.ussg.iu.edu/hypermail/linux/kernel/0311.1/0213.html
   More traces (roughly the same) available on request.
*  Some boards give bogus MAC addresses and work only partially.
   Same problem happens with nvnet on these boards.
*  Transmit for packets close to MTU size was broken, should be
   fixed now.

Please test.


Regards,
Carl-Daniel
