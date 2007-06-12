From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] CONFIG_INET depend on CONFIG_SYSCTL
Date: Tue, 12 Jun 2007 01:08:55 -0700 (PDT)
Message-ID: <20070612.010855.51301101.davem@davemloft.net>
References: <m2sl8xfwq8.wl%ysato@users.sourceforge.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: ysato@users.sourceforge.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60581
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752351AbXFLIIo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2007 04:08:44 -0400
In-Reply-To: <m2sl8xfwq8.wl%ysato@users.sourceforge.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yoshinori Sato <ysato@users.sourceforge.jp>
Date: Tue, 12 Jun 2007 16:38:55 +0900

> It cannot build with CONFIG_SYSCTL=n and CONFIG_INET=y.
> In case of CONFIG_INET=y it should become CONFIG_SYSCTL=y. 
> 
> Signed-off-by: Yoshinori Sato <ysato@users.sourceforge.jp>

1) Please post networking patches to netdev@vger.kernel.org
   which has been added to the CC:

2) It is much better to add the appropriate CONFIG_SYSCTL
   ifdefs to the INET code than to force it on for everyone.
