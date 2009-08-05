From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] ixgbe: allow vlan egress priority mapping in
 DCB mode
Date: Tue, 04 Aug 2009 19:44:27 -0700 (PDT)
Message-ID: <20090804.194427.180755602.davem@davemloft.net>
References: <20090805012726.24350.63928.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, lucy.liu@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41206
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933209AbZHECoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 22:44:19 -0400
In-Reply-To: <20090805012726.24350.63928.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 04 Aug 2009 18:27:28 -0700

> The skb priority to vlan-qos egress mapping that can be configured using
> set_egress_map with vconfig is overriden by the DCB code in the driver.
> 
> This patch allows this existing mechanism to work and will increase the
> configuration flexibility of DCB mode on Linux.

This is not the kind of bug fix which is appropriate at this
stage of -rcX development, so I'm only willing to put this
into net-next-2.6

Keep this in mind for future submissions for net-2.6
