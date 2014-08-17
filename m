From: David Miller <davem@davemloft.net>
Subject: Re: [net 0/3][pull request] Intel Wired LAN Driver Updates
 2014-08-15
Date: Sat, 16 Aug 2014 19:25:22 -0700 (PDT)
Message-ID: <20140816.192522.1351565465513320332.davem@davemloft.net>
References: <1408102673-27206-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57578 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751547AbaHQCZH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Aug 2014 22:25:07 -0400
In-Reply-To: <1408102673-27206-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 15 Aug 2014 04:37:50 -0700

> This series contains fixes to i40e only.
> 
> Anjali provides two fixes for i40e, first adds a check for non-active
> VF before sending admin queue messages to the VFS.  This resolves a
> potential kernel panic which would happen whenever we got a Tx hang and
> there were VFS that were not up or enabled.  The second fix adds
> additional checks so that we do try to access a VF that is not up or
> enabled which would dereference a null pointer.
> 
> Jesse fixes a i40e PTP bug where the hang detection routine was never
> being run when PTP was enabled.

Pulled, thanks Jeff.
