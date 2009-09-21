From: Jens Axboe <jens.axboe@oracle.com>
Subject: "cfg80211: fix SME connect" breaks iwl3945
Date: Mon, 21 Sep 2009 21:01:50 +0200
Message-ID: <20090921190150.GC23126@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org
To: Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from brick.kernel.dk ([93.163.65.50]:37353 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751114AbZIUTBr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Sep 2009 15:01:47 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Johannes,

Since the latest net pull that contains our above commit
(bbac31f4c0339f6c51afbd0edfb4959df9b53fa9 in tree), my iwl3945 based x60
laptop doesn't want to connect to my access point at all. Reverting this
commit makes it work.

Let me know if you need more info.

-- 
Jens Axboe

