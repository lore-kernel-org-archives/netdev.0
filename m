From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tulip: Properly check dma mapping result
Date: Thu, 13 Jun 2013 17:10:06 -0700 (PDT)
Message-ID: <20130613.171006.2068402793472112550.davem@davemloft.net>
References: <1371151888-12138-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, grundler@parisc-linux.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47918 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754716Ab3FNAKH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 20:10:07 -0400
In-Reply-To: <1371151888-12138-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Thu, 13 Jun 2013 15:31:28 -0400

> Tulip throws an error when dma debugging is enabled, as it doesn't properly
> check dma mapping results with dma_mapping_error() durring tx ring refills.
> 
> Easy fix, just add it in, and drop the frame if the mapping is bad
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Applied, thanks.
