From: Ming Lei <tom.leiming@gmail.com>
Subject: usbnet: fix misc bugs
Date: Mon, 30 Apr 2012 16:51:01 +0800
Message-ID: <1335775864-4873-1-git-send-email-tom.leiming@gmail.com>
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:41790 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751441Ab2D3IvP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 04:51:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches fix three bugs in usbnet:
	usbnet: fix leak of transfer buffer of dev->interrupt
	usbnet: fix failure handling in usbnet_probe
	usbnet: fix skb traversing races during unlink(v1)

 drivers/net/usb/usbnet.c   |   58 ++++++++++++++++++++++++++++++++------------
 include/linux/usb/usbnet.h |    3 ++-
 2 files changed, 44 insertions(+), 17 deletions(-)

Thanks,
--
Ming Lei
