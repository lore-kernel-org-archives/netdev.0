From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/9] i40e: use correct structure type name in sizeof
Date: Wed, 30 Jul 2014 19:14:17 -0700 (PDT)
Message-ID: <20140730.191417.1138940655186691666.davem@davemloft.net>
References: <1406647011-8543-1-git-send-email-Julia.Lawall@lip6.fr>
	<1406647011-8543-4-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, kernel-janitors@vger.kernel.org,
	linux-ia64@vger.kernel.org, ceph-devel@vger.kernel.org,
	toralf.foerster@gmx.de, hmh@hmh.eng.br, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	alexander.h.duyck@intel.com, john.ronciak@intel.com,
	mitch.a.williams@intel.com, linux.nics@intel.com,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38509 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751352AbaGaCOT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2014 22:14:19 -0400
In-Reply-To: <1406647011-8543-4-git-send-email-Julia.Lawall@lip6.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Tue, 29 Jul 2014 17:16:45 +0200

> From: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> Correct typo in the name of the type given to sizeof.  Because it is the
> size of a pointer that is wanted, the typo has no impact on compilation or
> execution.
> 
> This problem was found using Coccinelle (http://coccinelle.lip6.fr/).  The
> semantic patch used can be found in message 0 of this patch series.
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

I'll let the Intel driver folks pick this one up, thanks!
