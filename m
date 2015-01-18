From: Marcel Holtmann <marcel@holtmann.org>
Subject: Problem with  patch "make nlmsg_end() and genlmsg_end() void"
Date: Sun, 18 Jan 2015 03:44:58 -0800
Message-ID: <0397034D-1DF4-409F-B335-FCD0D7EAB940@holtmann.org>
Mime-Version: 1.0 (Mac OS X Mail 8.1 \(1993\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Gundersen <teg@jklm.no>
To: Network Development <netdev@vger.kernel.org>,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:51876 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751425AbbARLpF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2015 06:45:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Johannes,

your commit 053c095a82cf773075e83d7233b5cc19a1f73ece is causing problems with systemd-networkd.

I have an up-to-date Arch Linux installation in a KVM and your change causes massive problems. It makes systemd-networkd to run out of memory.

systemd-fsck[84]: /dev/vda1: clean, 53283/131072 files, 409813/524032 blocks
Out of memory: Kill process 142 (systemd-network) score 923 or sacrifice child
Killed process 142 (systemd-network) total-vm:478416kB, anon-rss:463472kB, file-rss:460kB
[FAILED] Failed to start Network Service.
See "systemctl status systemd-networkd.service" for details.
         Stopping Network Service...
[  OK  ] Stopped Network Service.
         Starting Network Service...

Arch Linux 3.19.0-rc4-devel+ (ttyS0)

marcel login: Out of memory: Kill process 154 (systemd-network) score 932 or sacrifice child
Killed process 154 (systemd-network) total-vm:540784kB, anon-rss:468380kB, file-rss:132kB
Out of memory: Kill process 158 (systemd-network) score 932 or sacrifice child
Killed process 158 (systemd-network) total-vm:540388kB, anon-rss:468528kB, file-rss:48kB
Out of memory: Kill process 160 (systemd-network) score 932 or sacrifice child
Killed process 160 (systemd-network) total-vm:540916kB, anon-rss:468528kB, file-rss:4kB
Out of memory: Kill process 162 (systemd-network) score 931 or sacrifice child
Killed process 162 (systemd-network) total-vm:540916kB, anon-rss:468104kB, file-rss:76kB

Regards

Marcel
