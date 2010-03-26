From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 2/2] ixgbe: filter FIP frames into the FCoE
 offload queues
Date: Fri, 26 Mar 2010 11:58:37 -0700 (PDT)
Message-ID: <20100326.115837.207504807.davem@davemloft.net>
References: <20100324224500.6653.28216.stgit@localhost.localdomain>
	<20100324224521.6653.17418.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	christopher.leech@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50482
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753224Ab0CZS6N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Mar 2010 14:58:13 -0400
In-Reply-To: <20100324224521.6653.17418.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 24 Mar 2010 15:45:21 -0700

> From: Chris Leech <christopher.leech@intel.com>
> 
> During FCF solicitation, the switch is supposed to pad the
> solicited advertisement out to the endpoints specified
> maximum FCoE frame size.  That means that we need to receive
> FIP frames that are larger than the standard MTU.  To make
> sure the receive queue is configured correctly, we should be
> filtering FIP traffic into the FCoE queues.
> 
> Signed-off-by: Chris Leech <christopher.leech@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
