From: Dan Carpenter <error27@gmail.com>
Subject: re: tlan: Code cleanup: checkpatch.pl is relatively happy now.
Date: Sun, 6 Feb 2011 13:43:30 +0300
Message-ID: <20110206104330.GA4384@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Sakari Ailus <sakari.ailus@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:34453 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751937Ab1BFKpI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Feb 2011 05:45:08 -0500
Received: by wwa36 with SMTP id 36so3857259wwa.1
        for <netdev@vger.kernel.org>; Sun, 06 Feb 2011 02:45:06 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit c659c38b279657 "tlan: Code cleanup: checkpatch.pl is relatively
happy now." includes the following change without explanation.

-               if ( ( head_list->cStat & TLAN_CSTAT_READY ) == TLAN_CSTAT_READY ) {
+               if (head_list->c_stat & TLAN_CSTAT_READY) {

Was this a bug fix or a bug introduce?

regards,
dan carpenter
