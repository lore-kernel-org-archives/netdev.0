From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 9/9] ixgbe: Fix potential memory leak/driver panic
 issue while setting up Tx & Rx ring parameters
Date: Thu, 02 Apr 2009 01:16:19 -0700 (PDT)
Message-ID: <20090402.011619.202997161.davem@davemloft.net>
References: <20090401073241.3749.36391.stgit@lost.foo-projects.org>
	<20090401073524.3749.21708.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	mallikarjuna.chilakala@intel.com, peter.p.waskiewicz.jr@intel.com,
	stable@kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60327
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759024AbZDBIQb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 04:16:31 -0400
In-Reply-To: <20090401073524.3749.21708.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 01 Apr 2009 00:35:24 -0700

> While setting up the ring parameters using ethtool the driver can
> panic or leak memory as ixgbe_open tries to setup tx & rx resources.
> The updated logic will use ixgbe_down/up after successful allocation of
> tx & rx resources
> 
> Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
