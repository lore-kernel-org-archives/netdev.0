From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/2] Enable SW only or HW only offloads
 with u32 classifier
Date: Mon, 16 May 2016 13:31:13 -0400 (EDT)
Message-ID: <20160516.133113.2239373107740584921.davem@davemloft.net>
References: <1463098103-2434-1-git-send-email-sridhar.samudrala@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org
To: sridhar.samudrala@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36540 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753485AbcEPRbP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 13:31:15 -0400
In-Reply-To: <1463098103-2434-1-git-send-email-sridhar.samudrala@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sridhar Samudrala <sridhar.samudrala@intel.com>
Date: Thu, 12 May 2016 17:08:21 -0700

> This set of patches export TCA_CLS_FLAGS_SKIP_HW to userspace and also
> introduces another flag TCA_CLS_FLAGS_SKIP_SW. These flags enable offloading 
> u32 filters to either SW or HW only.
> 
> The default semantics with no flags is to add the filter to HW if possible and
> also into SW. 
> With SKIP_HW flag, the filter is only added to SW.
> With SKIP_SW flag, the filter is added to HW and an error is returned
> to user on failure.
> These flags are mutually exclusive.
> There was an earlier discussion on these semantics in the following email
> thread.
> 	http://thread.gmane.org/gmane.linux.network/401733

Series applied, thanks.
