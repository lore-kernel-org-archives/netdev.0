From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] be2net: remove BUG_ON() in
 be_mcc_compl_is_new()
Date: Wed, 13 Feb 2013 13:53:59 -0500 (EST)
Message-ID: <20130213.135359.2148545579553285494.davem@davemloft.net>
References: <df52a8ca-fbd1-41aa-ad6f-995fd724a4d4@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43061 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756905Ab3BMSyB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2013 13:54:01 -0500
In-Reply-To: <df52a8ca-fbd1-41aa-ad6f-995fd724a4d4@CMEXHTCAS1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Wed, 13 Feb 2013 14:35:19 +0530

> The current code expects that the last word (with valid bit)
> of an MCC compl is DMAed in one shot. This may not be the case.
> Remove this assertion.
> 
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>

Applied.
