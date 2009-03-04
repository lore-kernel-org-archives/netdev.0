From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix tokenring license
Date: Tue, 03 Mar 2009 23:48:58 -0800 (PST)
Message-ID: <20090303.234858.249232039.davem@davemloft.net>
References: <Pine.SOC.4.64.0903031933400.26090@math.ut.ee>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mroos@linux.ee
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40544
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752198AbZCDHtN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 02:49:13 -0500
In-Reply-To: <Pine.SOC.4.64.0903031933400.26090@math.ut.ee>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Meelis Roos <mroos@linux.ee>
Date: Tue, 3 Mar 2009 20:11:26 +0200 (EET)

> Currently, modular tokenring ("tr") lacks a license and fails to load:
> 
> tr: module license 'unspecified' taints kernel.
> tr: Unknown symbol proc_net_fops_create
> 
> Beacuse of this, no tokenring driver can load if it depends on modular 
> tr. Fix this by adding GPL module license as it is in the kernel.
> 
> With this fix, tr module loads fine and tms380 driver also loads. Well, 
> it does'nt work but that's a different bug.
> 
> Signed-off-by: Meelis Roos <mroos@linux.ee>

Applied, thanks.
