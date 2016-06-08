From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net 0/2] incremental cls_u32 hardware offload fixes
Date: Wed,  8 Jun 2016 20:11:02 +0100
Message-ID: <1465413064-32196-1-git-send-email-jakub.kicinski@netronome.com>
Cc: john.r.fastabend@intel.com, sridhar.samudrala@intel.com,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:36260 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932362AbcFHTLz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 15:11:55 -0400
Received: by mail-wm0-f44.google.com with SMTP id n184so195124051wmn.1
        for <netdev@vger.kernel.org>; Wed, 08 Jun 2016 12:11:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These are incremental changes from v1 of cls_u32 fixes.
First patch is reposted in its entirety, patch 2 is an
incremental change from patch 2 of the original series.

Jakub Kicinski (2):
  net: cls_u32: catch all hardware offload errors
  net: cls_u32: be more strict about skip-sw flag (knode part)

 net/sched/cls_u32.c | 45 ++++++++++++++++++++++++++-------------------
 1 file changed, 26 insertions(+), 19 deletions(-)

-- 
1.9.1
