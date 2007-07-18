From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] ipt_iprange.h must #include <linux/types.h>
Date: Wed, 18 Jul 2007 02:22:24 -0700 (PDT)
Message-ID: <20070718.022224.69408970.davem@davemloft.net>
References: <20070715121419.GK3565@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cilly@cilly.mine.nu,
	netfilter-devel@lists.netfilter.org, linux-kernel@vger.kernel.org,
	kaber@coreworks.de
To: bunk@stusta.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55052
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751521AbXGRJWZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 05:22:25 -0400
In-Reply-To: <20070715121419.GK3565@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Sun, 15 Jul 2007 14:14:19 +0200

> ipt_iprange.h must #include <linux/types.h> since it uses __be32.
> 
> This patch fixes kernel Bugzilla #7604.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Applied, and I'll push this to -stable too, thanks Adrian.
