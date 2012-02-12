From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/7][pull request] Intel Wired LAN Driver Updates
Date: Sun, 12 Feb 2012 17:05:57 -0500 (EST)
Message-ID: <20120212.170557.518587781992613812.davem@davemloft.net>
References: <1328918904-11511-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57035 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753450Ab2BLWGB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Feb 2012 17:06:01 -0500
In-Reply-To: <1328918904-11511-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 10 Feb 2012 16:08:17 -0800

> The following series contains updates to ixgbe and skbuff.
> The skbuff patch helps reduce the overall size of sk_buff and the
> remaining patches are against ixgbe.  They do the following:
>  - refactor RSC and address that RSC was not setting GSO size
>  - combine post-DMA processing of sk_buff fields into 1 function
>  - drop _ADV since all descriptors are advanced
>  - improvements in the use of clear and status bits on Rx
> 
> The following are changes since commit d9dd966d7fc088a6bed991c2b1e2fba4485e0a31:
>   igb: fix warning about unused function
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Pulled, thanks.
