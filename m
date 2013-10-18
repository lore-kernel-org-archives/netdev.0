From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] be2net: pass if_id for v1 and V2 versions of TX_CREATE
 cmd
Date: Fri, 18 Oct 2013 16:33:08 -0400 (EDT)
Message-ID: <20131018.163308.1370734173997195267.davem@davemloft.net>
References: <1381990634-6847-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58221 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751712Ab3JRUdK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 16:33:10 -0400
In-Reply-To: <1381990634-6847-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Thu, 17 Oct 2013 11:47:14 +0530

> From: Vasundhara Volam <vasundhara.volam@emulex.com>
> 
> It is a required field for all TX_CREATE cmd versions > 0.
> This fixes a driver initialization failure, caused by recent SH-R Firmwares
> (versions > 10.0.639.0) failing the TX_CREATE cmd when if_id field is
> not passed.
> 
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
> ---
> 
> Dave, pls consider queuing this patch for -stable tree as it fixes
> a driver load failure. Thanks.

Applied and queued up for -stable, thanks.
