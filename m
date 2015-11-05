From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] decnet: remove macro-local declarations
Date: Thu, 05 Nov 2015 14:26:19 -0500 (EST)
Message-ID: <20151105.142619.983467860147585345.davem@davemloft.net>
References: <1446718696-32505-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org,
	linux-decnet-user@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, lkp@intel.com,
	roopa@cumulusnetworks.com, rshearma@brocade.com,
	ebiederm@xmission.com
To: Julia.Lawall@lip6.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38027 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752100AbbKET0X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2015 14:26:23 -0500
In-Reply-To: <1446718696-32505-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Thu,  5 Nov 2015 11:18:16 +0100

> Move the variable declarations from the for_nexthops macro to the
> surrounding context, so that it is clear where these variables are
> declared.  This also makes it possible to remove the endfor_nexthops macro.
> 
> This change adds new arguments to the macro for_nexthops.  They are ordered
> such that a pointer to the referenced object comes first, the index in the
> list comes next, and the list itself comes last, roughly in analogy with
> the list_for_each macros.
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> ---
> 
> This patch takes care of a single file, where the macros are defined
> locally.  If the basic transformation looks OK, I will change the other
> files that either likewise define their own macros or use the macros in
> net/mpls/internal.h.  The potentially affected files are:
 ...

This looks fine to me.

Please resubmit this when net-next opens back up, which should be
shortly after -rc1.

Thanks.
