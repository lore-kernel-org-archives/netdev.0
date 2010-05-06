From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/2] e1000/e1000e: implement a simple
 interrupt moderation
Date: Thu, 06 May 2010 00:25:47 -0700 (PDT)
Message-ID: <20100506.002547.13753501.davem@davemloft.net>
References: <20100505082537.5956.86868.stgit@localhost.localdomain>
	<20100505082601.5956.29024.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	jesse.brandeburg@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57063
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755377Ab0EFHZk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 03:25:40 -0400
In-Reply-To: <20100505082601.5956.29024.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 05 May 2010 01:26:03 -0700

> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> Back before e1000-7.3.20, the e1000 driver had a simple algorithm that
> managed interrupt moderation.  The driver was updated in 7.3.20 to
> have the new "adaptive" interrupt moderation but we have customer
> requests to redeploy the old way as an option.  This patch adds the
> old functionality back.  The new functionality can be enabled via
> module parameter or at runtime via ethtool.
> Module parameter: (InterruptThrottleRate=4) to use this new
> moderation method.
> Ethtool method: ethtool -C ethX rx-usecs 4
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
