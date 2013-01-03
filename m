From: Barry Grussling <barry@grussling.com>
Subject: [PATCH 0/4] DSA: Fix checkpatch.pl output for DSA drivers
Date: Wed,  2 Jan 2013 17:54:54 -0800
Message-ID: <1357178098-4057-1-git-send-email-barry@grussling.com>
To: barry@grussling.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f45.google.com ([209.85.210.45]:43547 "EHLO
	mail-da0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752757Ab3ACBzc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jan 2013 20:55:32 -0500
Received: by mail-da0-f45.google.com with SMTP id w4so6698244dam.4
        for <netdev@vger.kernel.org>; Wed, 02 Jan 2013 17:55:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set of patches performs routine maintenance on the DSA drivers
by removing all checkpatch.pl errors except for quoted strings 
crossing multiple lines.  

These patches do the following things:
 * Switch to network-style comments
 * Convert msleep calls to usleep_range calls
 * Convert printk calls to netdev_info calls
 * Fix whitespace issues

Let me know if you want the patches formatted differently/
squashed or anything else.  

Thanks,

   Barry

Barry Grussling (4):
  Convert DSA driver comments to network-style comments
  Convert msleep calls to usleep_range calls
  Convert printk calls to netdev_info calls
  Convert spaces to tabs where appropriate

 drivers/net/dsa/mv88e6060.c       |   36 +++++--------
 drivers/net/dsa/mv88e6123_61_65.c |  104 +++++++++++++----------------------
 drivers/net/dsa/mv88e6131.c       |   95 ++++++++++++--------------------
 drivers/net/dsa/mv88e6xxx.c       |  107 ++++++++++++++++---------------------
 drivers/net/dsa/mv88e6xxx.h       |   11 ++--
 5 files changed, 132 insertions(+), 221 deletions(-)

-- 
1.7.9.5
