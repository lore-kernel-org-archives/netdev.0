From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH 0/2 net-next] net: dsa: add private context accessor
Date: Mon, 28 Apr 2014 11:14:26 -0700
Message-ID: <1398708868-15084-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, buytenh@wantstofly.org,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:58737 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932085AbaD1TMy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2014 15:12:54 -0400
Received: by mail-pa0-f52.google.com with SMTP id kx10so6148597pab.25
        for <netdev@vger.kernel.org>; Mon, 28 Apr 2014 12:12:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lennert, David,

This patchset adds a private context accessors instead of doing the
(void *)(ds + 1) trick in DSA drivers that require the use of a private
context.

Florian Fainelli (2):
  net: dsa: add ds_to_priv
  net: dsa: update DSA drivers to use ds_to_priv

 drivers/net/dsa/mv88e6123_61_65.c |  2 +-
 drivers/net/dsa/mv88e6131.c       |  4 ++--
 drivers/net/dsa/mv88e6xxx.c       | 12 ++++++------
 include/net/dsa.h                 |  5 +++++
 4 files changed, 14 insertions(+), 9 deletions(-)

-- 
1.9.1
