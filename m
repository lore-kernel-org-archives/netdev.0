From: Weiping Pan <panweiping3@gmail.com>
Subject: [PATCH net V2 0/2] net: delete duplicate dev_set_rx_mode() call
Date: Mon, 16 Jun 2014 21:57:21 +0800
Message-ID: <cover.1402926490.git.panweiping3@gmail.com>
Cc: davem@davemloft.net, Weiping Pan <panweiping3@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:43645 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753420AbaFPN6H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2014 09:58:07 -0400
Received: by mail-pa0-f48.google.com with SMTP id et14so3240947pad.7
        for <netdev@vger.kernel.org>; Mon, 16 Jun 2014 06:58:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset delete duplicate dev_set_rx_mode() call, and it also make some
functions return void instead of int.

Weiping Pan (2):
  net: delete duplicate dev_set_rx_mode() call
  net: make some functions return void

 net/core/dev.c | 26 +++++++++-----------------
 1 file changed, 9 insertions(+), 17 deletions(-)

-- 
1.9.0
