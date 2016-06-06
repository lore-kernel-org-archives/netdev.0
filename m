From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net 0/2] cls_u32 hardware offload fixes
Date: Mon,  6 Jun 2016 16:16:46 +0100
Message-ID: <1465226208-32097-1-git-send-email-jakub.kicinski@netronome.com>
Cc: john.r.fastabend@intel.com, sridhar.samudrala@intel.com,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:38712 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751667AbcFFPTH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 11:19:07 -0400
Received: by mail-wm0-f48.google.com with SMTP id m124so76954333wme.1
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2016 08:19:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

This set fixes two small issues with error codes I noticed
in cls_u32.  Second patch could be viewed as user space API
change but that portion of API is not part of any release,
yet.

Compile tested only.

Jakub Kicinski (2):
  net: cls_u32: fix error code for invalid flags
  net: cls_u32: be more strict about skip-sw flag

 net/sched/cls_u32.c | 23 ++++++++++++-----------
 1 file changed, 12 insertions(+), 11 deletions(-)

-- 
1.9.1
