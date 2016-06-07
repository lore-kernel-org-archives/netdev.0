From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCHv2 net 0/2] cls_u32 hardware offload fixes
Date: Tue,  7 Jun 2016 11:46:54 +0100
Message-ID: <1465296416-21449-1-git-send-email-jakub.kicinski@netronome.com>
References: <1465226208-32097-1-git-send-email-jakub.kicinski@netronome.com>
Cc: john.r.fastabend@intel.com, sridhar.samudrala@intel.com,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:37727 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932293AbcFGKrJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 06:47:09 -0400
Received: by mail-wm0-f43.google.com with SMTP id k204so63163951wmk.0
        for <netdev@vger.kernel.org>; Tue, 07 Jun 2016 03:47:08 -0700 (PDT)
In-Reply-To: <1465226208-32097-1-git-send-email-jakub.kicinski@netronome.com>
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

 net/sched/cls_u32.c | 60 +++++++++++++++++++++++++++--------------------------
 1 file changed, 31 insertions(+), 29 deletions(-)

-- 
1.9.1
