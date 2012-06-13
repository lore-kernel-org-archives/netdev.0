From: Ming Lei <ming.lei@canonical.com>
Subject: usbnet: PM related fixes
Date: Wed, 13 Jun 2012 12:20:14 +0800
Message-ID: <1339561217-18151-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:49329 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750717Ab2FMEUe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2012 00:20:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The 3 patches fix some PM related problems.

Sorry for sending them after the cleanup patches since I found them just
after sending out the cleanup patches. 

 drivers/net/usb/usbnet.c |   47 +++++++++++++++++++++++++++++-----------------
 1 file changed, 30 insertions(+), 17 deletions(-)
