From: Sjur Braendeland <sjur.brandeland@stericsson.com>
Subject: [RFC arm-kernel 0/4] caif-u5500: CAIF shared memory/mailbox driver
Date: Tue, 12 Oct 2010 13:10:17 +0200
Message-ID: <1286881821-2916-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: stefan.xk.nilsson@stericsson.com, linus.walleij@stericsson.com,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	kim.lilliestierna@stericsson.com, daniel.martensson@stericsson.com,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: davem@davemloft.net, Russell King <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:33946 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757209Ab0JLLKx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Oct 2010 07:10:53 -0400
Received: by ewy20 with SMTP id 20so1136102ewy.19
        for <netdev@vger.kernel.org>; Tue, 12 Oct 2010 04:10:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>

This patch-set introduces the CAIF protocol driver for shared memory
over mailbox for u5500.

It implements the driver for transporting CAIF frames between the DB550=
0
modem portion and host side for the u5500 architecture.

The patches depends on the patch-set "U5500 mailbox driver and
modem irq handler" submitted on the linux-arm-kernel list by Stefan Nil=
sson.
http://www.arm.linux.org.uk/developer/patches/viewpatch.php?id=3D6417/1

These patches applies cleanly on latest linux-next git, but depends on
the U5500 mailbox driver for compilation.

Please note that the size and address of the shared memory are specifie=
d as module
parameters: shm_total_size, shm_start.

Regards,
Sjur Braendeland

Amarnath Revanna (4):
  caif-u5500: Adding shared memory include
  caif-u5500: CAIF shared memory transport protocol
  caif-u5500: CAIF shared memory mailbox interface
  caif-u5500: Build config for CAIF shared mem driver

 drivers/net/caif/Kconfig          |    7 +
 drivers/net/caif/Makefile         |    4 +
 drivers/net/caif/caif_shm_u5500.c |  129 ++++++
 drivers/net/caif/caif_shmcore.c   |  792 +++++++++++++++++++++++++++++=
++++++++
 include/net/caif/caif_shm.h       |   26 ++
 5 files changed, 958 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/caif/caif_shm_u5500.c
 create mode 100644 drivers/net/caif/caif_shmcore.c
 create mode 100644 include/net/caif/caif_shm.h

