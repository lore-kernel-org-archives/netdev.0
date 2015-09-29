From: =?UTF-8?Q?J=C3=B6rg_Otte?= <jrg.otte@gmail.com>
Subject: [v4.3.0-rc2->3] Regression: BIG networking performance loss
Date: Tue, 29 Sep 2015 18:32:03 +0200
Message-ID: <CADDKRnDgTkFudt-rsCCPub5iK=1hbmUUaxqrEO+_sg7JarEUQw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f193.google.com ([209.85.212.193]:36262 "EHLO
	mail-wi0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751196AbbI2QcF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 12:32:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With kernels vmlinuz-4.3.0-rc2-00228-gd4a748a and earlier it is no
problem for me to stream HD-videos (700-800 Kbyte/s) from YouTube.

With the same video material and kernels
vmlinuz-4.3.0-rc2-00438-gd8cc397 and later I only reach 70-80 KByte/s.
That's a one-tenth than before.

The merges between 00228 -> 00438 are:
d8cc397 Merge git://git.kernel.org/pub/scm/linux/kernel/git/herbert/cry=
pto-2.6
c91d707 Merge git://git.kernel.org/pub/scm/linux/kernel/git/nab/target-=
pending
bcba282 Merge tag 'usb-4.3-rc3' of
git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/usb
fb740f9 Merge tag 'tty-4.3-rc3' of
git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/tty
b11e7b8 Merge tag 'staging-4.3-rc3' of
git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/staging
7c1efea Merge tag 'driver-core-4.3-rc3' of
git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/driver-core
64b796e Merge tag 'char-misc-4.3-rc3' of
git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/char-misc
518a7cb Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net

Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168/8411
PCI Express Gigabit Ethernet Controller (rev 07)
Driver:r8169.

Thanks, J=C3=B6rg
