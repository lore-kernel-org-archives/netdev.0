From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v2] i40e: Fix i40e_print_features() VEB mode output
Date: Thu, 03 Dec 2015 11:49:46 -0500 (EST)
Message-ID: <20151203.114946.1155215569226167223.davem@davemloft.net>
References: <1449145257-110262-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: intel-wired-lan@lists.osuosl.org, joe@perches.com,
	netdev@vger.kernel.org, sergei.shtylyov@cogentembedded.com,
	shannon.nelson@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41264 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751621AbbLCQts (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 11:49:48 -0500
In-Reply-To: <1449145257-110262-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu,  3 Dec 2015 04:20:57 -0800

> From: Joe Perches <joe@perches.com>
> 
> Commit 7fd89545f337 ("i40e: remove BUG_ON from feature string building")
> added defective output when I40E_FLAG_VEB_MODE_ENABLED was set in
> function i40e_print_features.
> 
> Fix it.
> 
> Miscellanea:
> 
> - Remove unnecessary string variable
> - Add space before not after fixed strings
> - Use kmalloc not kzalloc
> - Don't initialize i to 0, use result of first snprintf
> 
> Reported-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
> v2: fixed patch conflicts when trying to apply to my next-queue tree
>     (dev-queue branch), also fixed "Noticed-by" to the more acceptable
>     "Reported-by"

Applied, thanks.
