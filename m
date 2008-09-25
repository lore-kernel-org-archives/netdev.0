From: Meelis Roos <mroos@linux.ee>
Subject: via-velocity warnings on sparc64
Date: Thu, 25 Sep 2008 11:15:54 +0300 (EEST)
Message-ID: <Pine.SOC.4.64.0809251007180.6342@math.ut.ee>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.it.da.ut.ee ([193.40.5.67]:57252 "EHLO smtp2.it.da.ut.ee"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751669AbYIYInZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Sep 2008 04:43:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Noticed this while compiling 2.6.27-rc7+git on sparc64 - maybe it is of 
interest.

  CC [M]  drivers/net/via-velocity.o
drivers/net/via-velocity.c: In function 'velocity_free_rd_ring':
drivers/net/via-velocity.c:1275: warning: cast from pointer to integer of different size
drivers/net/via-velocity.c: In function 'velocity_free_td_ring_entry':
drivers/net/via-velocity.c:1336: warning: cast from pointer to integer of different size

-- 
Meelis Roos (mroos@linux.ee)
