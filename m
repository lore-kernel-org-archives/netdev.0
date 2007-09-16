From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix net_device leak in vlan
Date: Sun, 16 Sep 2007 16:43:30 -0700 (PDT)
Message-ID: <20070916.164330.32095291.davem@davemloft.net>
References: <20070903133520.GV21089@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: viro@ftp.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42503
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753194AbXIPXna (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 19:43:30 -0400
In-Reply-To: <20070903133520.GV21089@ftp.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Al Viro <viro@ftp.linux.org.uk>
Date: Mon, 3 Sep 2007 14:35:20 +0100

> In "[VLAN]: Move device registation to seperate function" (commit
> e89fe42cd03c8fd3686df82d8390a235717a66de), a pile of code got moved
> to register_vlan_dev(), including grabbing a reference to underlying
> device.  However, original dev_hold() had been left behind, so we
> leak a reference to net_device now...
> 
> Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>

Patch applied, thanks Al.
