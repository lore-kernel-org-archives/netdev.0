From: Alessandro Suardi <alessandro.suardi@gmail.com>
Subject: ipw2200 in 2.6.15-rc2-git4 warns about improper NETDEV_TX_BUSY retcode
Date: Fri, 25 Nov 2005 00:38:32 +0100
Message-ID: <5a4c581d0511241538s496adee9s249cd038501545c9__49297.7359951057$1132875996$gmane$org@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dell Latitude D610, FC4 base distro, kernel is:

[asuardi@sandman ~]$ cat /proc/version
Linux version 2.6.15-rc2-git4 (asuardi@sandman) (gcc version 4.0.1
20050727 (Red Hat 4.0.1-5)) #2 Fri Nov 25 00:15:46 CET 2005

Onboard wireless card as detected by kernel is:
ipw2200: Intel(R) PRO/Wireless 2200/2915 Network Driver, git-1.0.8

 and I placed the 2.4 firmware from sourceforge.net in /lib/firmware.

ifup eth1 yields this message:

eth1: NETDEV_TX_BUSY returned; driver should report queue full via
ieee_device->is_queue_full.


I'm connected to my wireless DSL router while typing this mail
 so it obviously isn't fatal...


Thanks,

--alessandro

 "So much can happen by accident
  No rhyme, no reason - no one's innocent"

   (Steve Wynn - "Under The Weather")
