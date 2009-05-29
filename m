From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5] netdev: bfin_mac: fix crash when unloading module
Date: Fri, 29 May 2009 02:10:42 -0700 (PDT)
Message-ID: <20090529.021042.184273147.davem@davemloft.net>
References: <1243404615-25879-1-git-send-email-vapier@gentoo.org>
	<1243404615-25879-6-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org,
	graf.yang@analog.com
To: vapier@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57368
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752893AbZE2JKm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 05:10:42 -0400
In-Reply-To: <1243404615-25879-6-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier@gentoo.org>
Date: Wed, 27 May 2009 02:10:15 -0400

> If we build the Blackfin EMAC driver as a module and then unload it at
> runtime, it would cause a crash:
> root:/> rmmod bfin_mac

Actually, I reverted patch #4.

This bug is caused by patch #4, integrate this bug fix into
patch #4 and resubmit as one whole change.

Otherwise the tree is not properly bisectable.

Thank you.
