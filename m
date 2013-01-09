From: Barry Grussling <barry@grussling.com>
Subject: [PATCH V2 0/4] DSA: Fix checkpatch.pl output for DSA drivers
Date: Tue,  8 Jan 2013 18:05:52 -0800
Message-ID: <1357697156-5767-1-git-send-email-barry@grussling.com>
Cc: Barry Grussling <barry@grussling.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:39779 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753851Ab3AICGM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 21:06:12 -0500
Received: by mail-pa0-f53.google.com with SMTP id hz1so700624pad.26
        for <netdev@vger.kernel.org>; Tue, 08 Jan 2013 18:06:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set of patches performs routine maintenance on the DSA drivers
by removing all checkpatch.pl errors.

These patches do the following things:
 * Switch to network-style comments
 * Convert msleep calls to timeout/usleep_range calls
 * Convert printk calls to netdev_info calls
 * Fix whitespace issues

Changes from V1 of the patch include:
 (Joe Perches Review)
 * Change comment style to one-line for comments
   that can be reduced to one-line
 * Fix spelling of "Priority"
 * Remove device name from netdev_info
 * Coalesce netdev_info lines to one format line
 (Ben Hutchings Review)
 * Replace repeated usleep_range calls with
   timeouts/usleep_range calls.

Thanks,

   Barry

Barry Grussling (4):
  DSA: Convert DSA comments to network-style comments
  DSA: Convert repeated msleep calls to timeouts
  DSA: Convert printk calls to netdev_info calls
  DSA: Convert spaces to tabs where appropriate

 drivers/net/dsa/mv88e6060.c       |   54 ++++++--------
 drivers/net/dsa/mv88e6123_61_65.c |  125 +++++++++++---------------------
 drivers/net/dsa/mv88e6131.c       |  114 ++++++++++--------------------
 drivers/net/dsa/mv88e6xxx.c       |  141 +++++++++++++++----------------------
 drivers/net/dsa/mv88e6xxx.h       |   11 ++-
 5 files changed, 162 insertions(+), 283 deletions(-)

-- 
1.7.9.5
