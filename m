From: David Miller <davem@davemloft.net>
Subject: Re: [net,V2] vxlan: fix use-after-free on deletion
Date: Fri, 02 Jun 2017 14:30:05 -0400 (EDT)
Message-ID: <20170602.143005.1852140319389134982.davem@davemloft.net>
References: <1496363048-21138-1-git-send-email-markb@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbenc@redhat.com, roid@mellanox.com, roopa@cumulusnetworks.com,
        netdev@vger.kernel.org
To: markb@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46424 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750807AbdFBSaH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 14:30:07 -0400
In-Reply-To: <1496363048-21138-1-git-send-email-markb@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Bloch <markb@mellanox.com>
Date: Fri,  2 Jun 2017 03:24:08 +0300

> Adding a vxlan interface to a socket isn't symmetrical, while adding
> is done in vxlan_open() the deletion is done in vxlan_dellink().
> This can cause a use-after-free error when we close the vxlan
> interface before deleting it.
> 
> We add vxlan_vs_del_dev() to match vxlan_vs_add_dev() and call
> it from vxlan_stop() to match the call from vxlan_open().
> 
> Fixes: 56ef9c909b40 ("vxlan: Move socket initialization to within rtnl scope")
> Acked-by: Jiri Benc <jbenc@redhat.com>
> Tested-by: Roi Dayan <roid@mellanox.com>
> Signed-off-by: Mark Bloch <markb@mellanox.com>
> ---
> V2: Added a Fixes tag.
>     Added Acked-by and Tested-by from Jiri and Roi.

Applied and queued up for -stable, thanks.
