From: Alan Ott <alan@signal11.us>
Subject: [PATCH v4 0/2] Get and Set Feature Reports on HIDRAW (USB and Bluetooth)
Date: Mon, 16 Aug 2010 16:20:57 -0400
Message-ID: <1281990059-3562-1-git-send-email-alan__41385.8687891208$1281990106$gmane$org@signal11.us>
References: <1281442367.12579.206.camel@localhost.localdomain>
Cc: Alan Ott <alan@signal11.us>
To: Jiri Kosina <jkosina@suse.cz>,
	Stefan Achatz <erazor_de@users.sourceforge.net>,
	Antonio Ospite <ospite@studenti.unina.it>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Tejun Heo <tj@kernel
Return-path: <netdev-owner@vger.kernel.org>
Received: from core.signal11.us ([64.251.29.136]:46158 "EHLO core.signal11.us"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756521Ab0HPUVW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Aug 2010 16:21:22 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by core.signal11.us (Postfix) with SMTP id F19EF1CCAA45
	for <netdev@vger.kernel.org>; Mon, 16 Aug 2010 16:21:21 -0400 (EDT)
In-Reply-To: <1281442367.12579.206.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is version 4. Built against 2.6.35+ revision 320b2b8de12698 .

Alan Ott (2):
  HID: Add Support for Setting and Getting Feature Reports from hidraw
  Bluetooth: hidp: Add support for hidraw  HIDIOCGFEATURE  and
    HIDIOCSFEATURE

 drivers/hid/hidraw.c          |  105 ++++++++++++++++++++++++++++++++++++--
 drivers/hid/usbhid/hid-core.c |   37 +++++++++++++-
 include/linux/hid.h           |    3 +
 include/linux/hidraw.h        |    3 +
 net/bluetooth/hidp/core.c     |  114 +++++++++++++++++++++++++++++++++++++++--
 net/bluetooth/hidp/hidp.h     |    8 +++
 6 files changed, 260 insertions(+), 10 deletions(-)


