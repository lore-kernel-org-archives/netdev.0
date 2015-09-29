From: David Miller <davem@davemloft.net>
Subject: Re: [net] i40e/i40evf: check for stopped admin queue
Date: Mon, 28 Sep 2015 20:58:19 -0700 (PDT)
Message-ID: <20150928.205819.8431611779914202.davem@davemloft.net>
References: <1443486686-49798-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mitch.a.williams@intel.com, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52880 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932337AbbI2D6U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2015 23:58:20 -0400
In-Reply-To: <1443486686-49798-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 28 Sep 2015 17:31:26 -0700

> From: Mitch Williams <mitch.a.williams@intel.com>
> 
> It's possible that while we are waiting for the spinlock, another
> entity (that owns the spinlock) has shut down the admin queue.
> If we then attempt to use the queue, we will panic.
> 
> Add a check for this condition on the receive side. This matches
> an existing check on the send queue side.
> 
> Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
> Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
