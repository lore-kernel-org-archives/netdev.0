From: David Miller <davem@davemloft.net>
Subject: Re: [net 0/4][pull request] Intel Wired LAN Driver Updates
 2014-10-16
Date: Thu, 16 Oct 2014 14:43:47 -0400 (EDT)
Message-ID: <20141016.144347.422758922524209546.davem@davemloft.net>
References: <1413452187-2950-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33402 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751636AbaJPSnx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2014 14:43:53 -0400
In-Reply-To: <1413452187-2950-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 16 Oct 2014 02:36:23 -0700

> This series contains updates to fm10k and ixgbe.
> 
> Matthew provides two fixes for fm10k, first sets the flag to fetch the
> host state before kicking off the service task that reads the host
> state when bringing the interface up.  The second makes sure that we
> release the mailbox lock after detecting an error and before we return
> the error code.
> 
> Andy Zhou provides a compile fix for fm10k, when the driver is compiled
> into the kernel and the VXLAN driver is compiled as a module.
> 
> Emil provides a fix for ixgbe to prevent against a panic by trying
> to dereference a NULL pointer in ixgbe_ndo_set_vf_spoofchk().

Series applied, thanks Jeff.
