From: Peter Korsgaard <peter@korsgaard.com>
Subject: [PATCH 0/4] dm9601: improve support for dm962x based devices
Date: Mon, 16 Dec 2013 11:35:31 +0100
Message-ID: <1387190135-17052-1-git-send-email-peter@korsgaard.com>
Cc: joseph_chang@davicom.com.tw, Peter Korsgaard <peter@korsgaard.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f50.google.com ([74.125.83.50]:51227 "EHLO
	mail-ee0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751112Ab3LPKfs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 05:35:48 -0500
Received: by mail-ee0-f50.google.com with SMTP id c41so2164445eek.9
        for <netdev@vger.kernel.org>; Mon, 16 Dec 2013 02:35:47 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contain a number of improvements/fixes for the USB 2.0
dm962x based devices. Two of them are bugfixes, so are also marked for
stable.

Peter Korsgaard (4):
  dm9601: add support for dm9621a based dongle
  dm9601: fix reception of full size ethernet frames on dm9620/dm9621a
  dm9601: make it clear that dm9620/dm9621a are also supported
  dm9601: work around tx fifo sync issue on dm962x

 drivers/net/usb/Kconfig  |  6 +++---
 drivers/net/usb/dm9601.c | 44 ++++++++++++++++++++++++++++++++------------
 2 files changed, 35 insertions(+), 15 deletions(-)

-- 
1.8.5.1
