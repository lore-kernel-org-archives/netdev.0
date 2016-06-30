From: David Miller <davem@davemloft.net>
Subject: Re: [patch] be2net: signedness bug in be_msix_enable()
Date: Thu, 30 Jun 2016 08:56:26 -0400 (EDT)
Message-ID: <20160630.085626.1553236786452459332.davem@davemloft.net>
References: <20160629143943.GA22818@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sathya.perla@broadcom.com, ajit.khaparde@broadcom.com,
	sriharsha.basavapatna@broadcom.com, somnath.kotur@broadcom.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55695 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751994AbcF3M44 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 08:56:56 -0400
In-Reply-To: <20160629143943.GA22818@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 29 Jun 2016 17:39:43 +0300

> "num_vec" needs to be signed for the error handling to work.
> 
> Fixes: e261768e9e39 ('be2net: support asymmetric rx/tx queue counts')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
