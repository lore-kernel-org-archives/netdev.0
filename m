From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3][net-next] gianfar: Pack struct gfar_priv_grp into
 three cachelines
Date: Tue, 29 Jan 2013 15:22:39 -0500 (EST)
Message-ID: <20130129.152239.1707330330071893720.davem@davemloft.net>
References: <1359467712-32079-1-git-send-email-claudiu.manoil@freescale.com>
	<1359467712-32079-2-git-send-email-claudiu.manoil@freescale.com>
	<1359467712-32079-3-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: claudiu.manoil@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59862 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752187Ab3A2UWk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 15:22:40 -0500
In-Reply-To: <1359467712-32079-3-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claudiu Manoil <claudiu.manoil@freescale.com>
Date: Tue, 29 Jan 2013 15:55:12 +0200

> * remove unused members(!): imask, ievent
> * move space consuming interrupt name strings (int_name_* members) to
> external structures, unessential for the driver's hot path
> * keep high priority hot path data within the first 2 cache lines
> 
> This reduces struct gfar_priv_grp from 6 to 3 cache lines.
> (Also fixed checkpatch warnings for the old code, in the process.)
> 
> Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>

Applied.
