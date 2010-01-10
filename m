From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 00/13] virtual function ixgbe driver
Date: Sun, 10 Jan 2010 13:35:24 -0800 (PST)
Message-ID: <20100110.133524.238553933.davem@davemloft.net>
References: <20100109120719.4462.66489.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46023
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753334Ab0AJVfP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2010 16:35:15 -0500
In-Reply-To: <20100109120719.4462.66489.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat, 09 Jan 2010 04:22:54 -0800

> The following series implements the ixgbevf driver.  This series of patches
> has the following known issues:
> 
> - ixgbevf multiple load/unload can cause a panic
> - loading ixgbevf before ixgbe does not work
> - Tx hangs on VF interfaces - this happens when various resets, mostly due to
>   ethtool operations are executed while passing traffic
> 
> We are looking for inclusion into net-next-2.6 so that we can get assistance
> from the community in testing and further development of this driver.

Applied.

We can pull it out if things can't be resolve sufficiently, but
I seriously doubt these problems will persist that long :-)
