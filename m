From: Benoit Taine <benoit.taine@lip6.fr>
Subject: [PATCH 0/18] Use kmemdup instead of kmalloc + memcpy
Date: Mon, 26 May 2014 17:21:09 +0200
Message-ID: <1401117687-28911-1-git-send-email-benoit.taine@lip6.fr>
Cc: benoit.taine@lip6.fr, dri-devel@lists.freedesktop.org,
	devel@driverdev.osuosl.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, wcn36xx@lists.infradead.org,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	usb-storage@lists.one-eyed-alien.net, linux-scsi@vger.kernel.org,
	DL-MPTFusionLinux@lsi.com, linux-input@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: linux-media@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches enhance kernel style usage, and allows smaller code while
preventing accidental code edits to produce overflows.

The semantic patch at scripts/coccinelle/api/memdup.cocci was used to
detect and edit this situation.
