From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCHv3 net 0/3] cls_u32 hardware offload fixes
Date: Tue,  7 Jun 2016 23:17:00 +0100
Message-ID: <1465337823-16096-1-git-send-email-jakub.kicinski@netronome.com>
References: <1465226208-32097-1-git-send-email-jakub.kicinski@netronome.com>
Cc: john.r.fastabend@intel.com, sridhar.samudrala@intel.com,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:37436 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756300AbcFGWRN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 18:17:13 -0400
Received: by mail-wm0-f45.google.com with SMTP id k204so87631490wmk.0
        for <netdev@vger.kernel.org>; Tue, 07 Jun 2016 15:17:12 -0700 (PDT)
In-Reply-To: <1465226208-32097-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

This set fixes three small issues with error codes I noticed
in cls_u32.  Second patch could be viewed as user space API
change but that portion of API is not part of any release,
yet.

Very lightly tested.

Jakub Kicinski (3):
  net: cls_u32: fix error code for invalid flags
  net: cls_u32: be more strict about skip-sw flag
  net: cls_u32: catch all hardware offload errors

 net/sched/cls_u32.c | 68 ++++++++++++++++++++++++++++++-----------------------
 1 file changed, 38 insertions(+), 30 deletions(-)

-- 
1.9.1
