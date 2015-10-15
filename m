From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ethtool: Use kcalloc instead of kmalloc for
 ethtool_get_strings
Date: Wed, 14 Oct 2015 19:01:43 -0700 (PDT)
Message-ID: <20151014.190143.1146798720952847167.davem@davemloft.net>
References: <1444805996-3877-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1444805996-3877-16-git-send-email-jeffrey.t.kirsher@intel.com>
	<1444810180.2718.16.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, jacob.e.keller@intel.com,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, bruce.w.allan@intel.com, ben@decadent.org.uk
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38222 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754752AbbJOBpj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 21:45:39 -0400
In-Reply-To: <1444810180.2718.16.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Wed, 14 Oct 2015 01:09:40 -0700

> It seems that kernel memory can leak into userspace by a
> kmalloc, ethtool_get_strings, then copy_to_user sequence.
> 
> Avoid this by using kcalloc to zero fill the copied buffer.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied and queued up for -stable, thanks Joe.
