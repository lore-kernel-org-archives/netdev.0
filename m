From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/10] bnx2x: Feature (+semantic) patch series
Date: Wed, 04 Apr 2012 01:38:49 -0400 (EDT)
Message-ID: <20120404.013849.1985957445847339438.davem@davemloft.net>
References: <1333514492-20425-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41864 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751099Ab2DDFi4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 01:38:56 -0400
In-Reply-To: <1333514492-20425-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yuval Mintz" <yuvalmin@broadcom.com>
Date: Wed, 4 Apr 2012 07:41:22 +0300

> This patch series contains several patch, some of them semantic in
> nature (removing dead code, fixing styling issues), while others
> include new features, such as support for the new 57811 device and
> remote fault detection.
> 
> Please consider applying this patch series to 'net-next'.

All applied, thanks.

Although I wonder about that intx thing.  I thought that at
some point it was agreed that the generic PCI code should
bring devices up in INTX mode so that this can be relied
upon in the drivers.

Or I could be mis-remembering :-)
