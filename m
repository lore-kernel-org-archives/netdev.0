From: David Miller <davem@davemloft.net>
Subject: Re: [net] GRE: enable offloads for GRE
Date: Fri, 11 Jul 2014 13:54:34 -0700 (PDT)
Message-ID: <20140711.135434.2199154793674154732.davem@davemloft.net>
References: <1405038561-14852-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amritha.nambiar@intel.com, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com,
	joseph.gasparakis@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57412 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751999AbaGKUyf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2014 16:54:35 -0400
In-Reply-To: <1405038561-14852-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 10 Jul 2014 17:29:21 -0700

> From: Amritha Nambiar <amritha.nambiar@intel.com>
> 
> To get offloads to work with Generic Routing Encapsulation (GRE), the
> outer transport header has to be reset after skb_push is done. This
> patch has the support for this fix and hence GRE offloading.
> 
> Signed-off-by: Amritha Nambiar <amritha.nambiar@intel.com>
> Signed-off-by: Joseph Gasparakis <joseph.gasparakis@intel.com>
> Tested-By: Jim Young <jamesx.m.young@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

I think, generally speaking, this is more about making sure the
SKB is in a proper state.  If that happens to make offloads over
GRE work properly, that's certainly a nice side effect :)

Applied, thanks.
