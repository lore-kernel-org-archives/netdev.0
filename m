From: Weiping Pan <panweiping3@gmail.com>
Subject: [PATCH net 0/2] net: delete duplicate dev_set_rx_mode() call
Date: Sun, 15 Jun 2014 18:05:08 +0800
Message-ID: <cover.1402826534.git.panweiping3@gmail.com>
Cc: davem@davemloft.net, edumazet@google.com,
	Weiping Pan <panweiping3@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:47755 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750824AbaFOKF5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jun 2014 06:05:57 -0400
Received: by mail-pa0-f42.google.com with SMTP id lj1so3508301pab.15
        for <netdev@vger.kernel.org>; Sun, 15 Jun 2014 03:05:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset delete duplicate dev_set_rx_mode() call, and it also make some
functions return void instead of int.

Weiping Pan (2):
  net: delete duplicate dev_set_rx_mode() call
  net: make some functions return void

 net/core/dev.c | 23 ++++++++---------------
 1 file changed, 8 insertions(+), 15 deletions(-)

-- 
1.9.0
