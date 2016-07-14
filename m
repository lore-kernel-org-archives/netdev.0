From: Oliver Neukum <oneukum@suse.com>
Subject: [PATCH 0 / 5] move the common CDC parser
Date: Thu, 14 Jul 2016 15:41:29 +0200
Message-ID: <1468503694-9482-1-git-send-email-oneukum@suse.com>
To: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, gregKH@linuxfoundation.org, bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:37001 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751464AbcGNNp7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jul 2016 09:45:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Experience has shown that making all CDC drivers depend on usbnet
is not practical, because some of them are not network drivers.
So this patch moves the common parser from usbnet into the messages
helpers of usbcore.
The rest of the series applies it to the non-network CDC drivers.

I hope it can go through Greg's tree although it touches usbnet.
