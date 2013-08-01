From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][net-next] gianfar: Remove unused field grp_id from
 gfar_priv_grp
Date: Thu, 01 Aug 2013 13:16:42 -0700 (PDT)
Message-ID: <20130801.131642.2217532927385884718.davem@davemloft.net>
References: <1375340825-6524-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: claudiu.manoil@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53480 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753271Ab3HAUQn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 16:16:43 -0400
In-Reply-To: <1375340825-6524-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claudiu Manoil <claudiu.manoil@freescale.com>
Date: Thu, 1 Aug 2013 10:07:05 +0300

> grp->grp_id is obsolete. It has no use in the current driver.
> Remove it from gfar_priv_grp and put the 'rstat' member
> in its place, in the 2nd cache line, as rstat needs fast access.
> 
> Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>

Looks good, applied, thanks.
