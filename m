From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] fix net_device leak in vlan
Date: Mon, 03 Sep 2007 16:23:05 +0200
Message-ID: <46DC18C9.8090501@trash.net>
References: <20070903133520.GV21089@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Al Viro <viro@ftp.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45314 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754108AbXICOXe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Sep 2007 10:23:34 -0400
In-Reply-To: <20070903133520.GV21089@ftp.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Al Viro wrote:
> In "[VLAN]: Move device registation to seperate function" (commit
> e89fe42cd03c8fd3686df82d8390a235717a66de), a pile of code got moved
> to register_vlan_dev(), including grabbing a reference to underlying
> device.  However, original dev_hold() had been left behind, so we
> leak a reference to net_device now...


Looks good, thanks for catching this.
