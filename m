From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] skb: Add documentation for skb_clone_sk
Date: Tue, 09 Sep 2014 17:20:52 -0700 (PDT)
Message-ID: <20140909.172052.312397302813323066.davem@davemloft.net>
References: <20140908161748.13099.29093.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, richardcochran@gmail.com
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34198 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752819AbaIJAUx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 20:20:53 -0400
In-Reply-To: <20140908161748.13099.29093.stgit@ahduyck-bv4.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Mon, 08 Sep 2014 12:18:22 -0400

> This change adds some documentation to the call skb_clone_sk.  This is
> meant to help clarify the purpose of the function for other developers.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

Since there is still active discussion about whether the socket
refcounting is even handled correctly by these mechanisms, I
am deferring on this patch for now.
