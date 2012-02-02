From: David Miller <davem@davemloft.net>
Subject: Re: [net 4/8] ixgbe: fix namespace issues when FCoE is not enabled
Date: Thu, 02 Feb 2012 14:20:05 -0500 (EST)
Message-ID: <20120202.142005.1066192595268413170.davem@davemloft.net>
References: <1328185221-8591-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1328185221-8591-5-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44709 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754290Ab2BBTUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2012 14:20:12 -0500
In-Reply-To: <1328185221-8591-5-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu,  2 Feb 2012 04:20:17 -0800

> Several functions are made external but are not used externally when
> FCoE/DCB is not enabled.
> 
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>

Do not crap up the *.c files with ifdefs like this.

Better to export these operations via an ops structure of
some kind, rather than doing stuff like this.

I'm not applying this series if it contains stuff like
this.
