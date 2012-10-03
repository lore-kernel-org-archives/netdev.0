From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] bnx2x: fix ring size for 10G functions
Date: Wed, 03 Oct 2012 16:36:12 -0400 (EDT)
Message-ID: <20121003.163612.1957153988621338196.davem@davemloft.net>
References: <1349274179-18827-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ariele@broadcom.com, eilong@broadcom.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32855 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753766Ab2JCUgQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2012 16:36:16 -0400
In-Reply-To: <1349274179-18827-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yuval Mintz" <yuvalmin@broadcom.com>
Date: Wed, 3 Oct 2012 16:22:59 +0200

> Commit d760fc37b0f74502b3f748951f22c6683b079a8e caused 
> 1G functions to allocate rx rings which were 1/10 of the 
> size of 10G functions' rx rings.
> 
> However, it also caused 10G functions on 5771x boards to 
> allocate small rings, which limits their possible (default) 
> rx throughput. This patch causes all 10G functions to use 
> rings of intended length by default.
> 
> Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> Signed-off-by: Ariel Elior <ariele@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
