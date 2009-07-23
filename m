From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 2/2] ixgbe: Don't priority tag control frames
 in DCB mode
Date: Thu, 23 Jul 2009 11:06:14 -0700 (PDT)
Message-ID: <20090723.110614.180424233.davem@davemloft.net>
References: <20090723000705.27299.19299.stgit@localhost.localdomain>
	<20090723000733.27299.56014.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, lucy.liu@intel.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59482
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751658AbZGWSGI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2009 14:06:08 -0400
In-Reply-To: <20090723000733.27299.56014.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 22 Jul 2009 17:07:33 -0700

> From: Lucy Liu <lucy.liu@intel.com>
> 
> Certain types of control packets (LLDP, LACP, etc.) are not supposed to have a
> priority tag or vlan tag inserted.  Ixgbe driver is currently priority
> tagging everything (if packet is not on a VLAN interface).
> 
> This patch modifies DCB mode, so that packets marked with skb priority
> TC_PRIO_CONTROL are not priority tagged.  It also transmits these packets on
> the highest priority traffic class.
> Programs (like dcbd) can set the skb priority using a socket option.  Or, a tc
> filter can be configured to set the priority value. Using the value
> TC_PRIO_CONTROL (7) has the benefit that it is already defined in the kernel,
> and the bonding LACP code already sets the skb->priority field to this value.
> 
> Signed-off-by: Lucy Liu <lucy.liu@intel.com>
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
