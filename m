From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: add gfp parameter to tcp_fragment
Date: Tue, 10 Jun 2014 22:31:40 -0700 (PDT)
Message-ID: <20140610.223140.1388530525868582790.davem@davemloft.net>
References: <1402065157-29595-1-git-send-email-octavian.purdila@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, christoph.paasch@uclouvain.be
To: octavian.purdila@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42570 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752087AbaFKFbl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 01:31:41 -0400
In-Reply-To: <1402065157-29595-1-git-send-email-octavian.purdila@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Octavian Purdila <octavian.purdila@intel.com>
Date: Fri,  6 Jun 2014 17:32:37 +0300

> tcp_fragment can be called from process context (from tso_fragment).
> Add a new gfp parameter to allow it to preserve atomic memory if
> possible.
> 
> Signed-off-by: Octavian Purdila <octavian.purdila@intel.com>
> Reviewed-by: Christoph Paasch <christoph.paasch@uclouvain.be>

Applied to net-next, thanks.
