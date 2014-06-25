From: David Miller <davem@davemloft.net>
Subject: Re: Stable request for 5882a07c72093d
Date: Wed, 25 Jun 2014 16:11:18 -0700 (PDT)
Message-ID: <20140625.161118.667949733868205928.davem@davemloft.net>
References: <1403539016-15519-1-git-send-email-chiluk@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, weichunc@plumgrid.com
To: chiluk@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39037 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756320AbaFYXLT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 19:11:19 -0400
In-Reply-To: <1403539016-15519-1-git-send-email-chiluk@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Chiluk <chiluk@canonical.com>
Date: Mon, 23 Jun 2014 10:56:55 -0500

> Commit 5882a07c72093dc3a18e2d2b129fb200686bb6ee remedies a BUG_ON in
> skb_segment.  This is hit reliably in clouds that are using openvswitch for
> network capabilities (which is the default network used by Openstack) on
> machines that have gso offload capabilities.  
> 
> This has already been reported multiple times to Canonical in numerous
> openstack clouds.  The fix has been integrated and tested in those clouds, and
> has been show to resolve their issues.
> 
> Please include this patch for stable release.

Queued up for -stable submission, thank you.
