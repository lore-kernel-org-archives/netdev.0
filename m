From: David Miller <davem@davemloft.net>
Subject: Re: [net 0/4][pull request] Intel Wired LAN Driver Updates
 2014-10-30
Date: Thu, 30 Oct 2014 19:47:41 -0400 (EDT)
Message-ID: <20141030.194741.1619320241221233019.davem@davemloft.net>
References: <1414672436-20616-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60985 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161293AbaJ3Xro (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 19:47:44 -0400
In-Reply-To: <1414672436-20616-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 30 Oct 2014 05:33:52 -0700

> This series contains updates to e1000, igb and ixgbe.
> 
> Francesco Ruggeri fixes an issue with e1000 where in a VM the driver did
> not support unicast filtering.
> 
> Roman Gushchin fixes an issue with igb where the driver was re-using
> mapped pages so that packets were still getting dropped even if all
> the memory issues are gone and there is free memory.
> 
> Junwei Zhang found where in the ixgbe_clean_rx_ring() we were repeating
> the assignment of NULL to the receive buffer skb and fixes it.
> 
> Emil fixes a race condition between setup_link and SFP detection routine
> in the watchdog when setting the advertised speed.

Pulled, thanks Jeff.
