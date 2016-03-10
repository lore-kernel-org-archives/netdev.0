From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] kcm: mark helper functions inline
Date: Thu, 10 Mar 2016 14:48:34 -0500 (EST)
Message-ID: <20160310.144834.1932393637184383729.davem@davemloft.net>
References: <1457634674-3373509-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50611 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753194AbcCJTsg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2016 14:48:36 -0500
In-Reply-To: <1457634674-3373509-1-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 10 Mar 2016 19:31:12 +0100

> The stub helper functions for the newly added kcm_proc_init/exit interfaces
> are defined as 'static' in a header file, which leads to build warnings for
> each file that includes them without calling them:
> 
> include/net/kcm.h:183:12: error: 'kcm_proc_init' defined but not used [-Werror=unused-function]
> include/net/kcm.h:184:13: error: 'kcm_proc_exit' defined but not used [-Werror=unused-function]
> 
> This marks the two functions as 'static inline' instead, which avoids the
> warnings and is obviously what was meant here.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: cd6e111bf5be ("kcm: Add statistics and proc interfaces")

Applied, thanks Arnd.
