From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH -v1 0/3] usbnet: usbnet: PM related fixes
Date: Wed, 20 Jun 2012 15:15:50 +0800
Message-ID: <1340176553-32225-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:65505 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753275Ab2FTHQM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 03:16:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The 3 patches fix some PM related problems.

v1:
	- one line fix in 3/3: GFP_ATOMIC -> flags in rx_alloc_submit

 drivers/net/usb/usbnet.c |   47 +++++++++++++++++++++++++++++-----------------
 1 file changed, 30 insertions(+), 17 deletions(-)

Thanks,
--
Ming Lei
