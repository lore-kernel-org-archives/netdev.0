From: Varka Bhadram <varkabhadram@gmail.com>
Subject: [PATCH net-next 0/2] cleanup for 6lowpan and mac802514
Date: Thu, 26 Jun 2014 19:06:53 +0530
Message-ID: <1403789815-10418-1-git-send-email-varkab@cdac.in>
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net,
	Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:54157 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755000AbaFZNiX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2014 09:38:23 -0400
Received: by mail-pb0-f49.google.com with SMTP id rr13so3140511pbb.8
        for <netdev@vger.kernel.org>; Thu, 26 Jun 2014 06:38:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches fixed the coding style issues reported by checkpatch.pl.

following issues fixed:
	CHECK: Alignment should match open parenthesis
	WARNING: Prefer kcalloc over kzalloc with multiply
	WARNING: line over 80 characters
	CHECK: Blank lines aren't necessary before a close brace '}'
	WARNING: networking block comments don't use an empty /* line, use /* Comment...
	WARNING: Missing a blank line after declarations
	WARNING: networking block comments start with * on subsequent lines
	CHECK: braces {} should be used on all arms of this statement

Varka Bhadram (2):
  6lowpan: fix coding style issues
  mac802154: fix coding style issues

 net/ieee802154/6lowpan_iphc.c  |  113 ++++++++++++++++++----------------------
 net/ieee802154/6lowpan_rtnl.c  |   16 +++---
 net/ieee802154/af_ieee802154.c |   26 +++++----
 net/ieee802154/dgram.c         |   28 +++++-----
 net/ieee802154/ieee802154.h    |    2 +-
 net/ieee802154/netlink.c       |    4 +-
 net/ieee802154/nl-mac.c        |   48 +++++++++--------
 net/ieee802154/nl-phy.c        |   25 +++++----
 net/ieee802154/raw.c           |   14 +++--
 net/ieee802154/reassembly.c    |    1 +
 net/ieee802154/wpan-class.c    |   10 ++--
 net/mac802154/ieee802154_dev.c |    4 +-
 net/mac802154/llsec.c          |    1 +
 net/mac802154/mib.c            |    7 +--
 net/mac802154/tx.c             |    1 +
 15 files changed, 154 insertions(+), 146 deletions(-)

-- 
1.7.9.5
