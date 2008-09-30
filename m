From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] netdev: use const for some name functions
Date: Tue, 30 Sep 2008 02:22:59 -0700 (PDT)
Message-ID: <20080930.022259.135964752.davem@davemloft.net>
References: <20080923083934.032d6098@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39286
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751642AbYI3JXL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2008 05:23:11 -0400
In-Reply-To: <20080923083934.032d6098@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 23 Sep 2008 08:39:34 -0700

> dev_change_name and netdev_drivername should use const char on parameters
> that are read-only input values. The strcpy to newname is not needed since
> newname is not used later in function.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied to net-next-2.6
