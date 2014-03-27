From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 0/2] be2net: add vxlan offload support
Date: Thu, 27 Mar 2014 15:52:36 -0400 (EDT)
Message-ID: <20140327.155236.1697998322894080153.davem@davemloft.net>
References: <1395897379-29141-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57500 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755024AbaC0Twj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 15:52:39 -0400
In-Reply-To: <1395897379-29141-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Thu, 27 Mar 2014 10:46:17 +0530

> The first patch adds the FW cmds needed to configure the Skyhawk-R
> chip for supporting VxLAN offloads. The second patch implements the
> ndo_add/del_vxlan_port() methods and the plumbing for supporting
> RX/TX csum, TSO and RSS steering offloads for VxLAN traffic.
> 
> v2 changes:
> NETIF_F_SG need not be set for hw_enc_features by the driver as it is
> done by the stack.
> 
> v3 changes:
> * Defer FW cmds needed for VxLAN offloads to a workqueue
> * Reset FW to VxLAN offloads disabled state in the unload path
> 
> v4 changes:
> * Revert the usage of workqueue (introduced in v3) to implement
> ndo_add/del_vxlan_port() as it is currently not needed (none of the
> FW cmd calls sleep.) Suggested by David M.
> 
> Pls apply. Thanks.

Series applied, thanks.
