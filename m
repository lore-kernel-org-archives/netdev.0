From: David Miller <davem@davemloft.net>
Subject: Re: [net] vxlan: fix use-after-free on deletion
Date: Thu, 01 Jun 2017 11:54:39 -0400 (EDT)
Message-ID: <20170601.115439.2242460950378515228.davem@davemloft.net>
References: <1496306615-770-1-git-send-email-markb@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbenc@redhat.com, roopa@cumulusnetworks.com, netdev@vger.kernel.org
To: markb@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56342 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751684AbdFAPyl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 11:54:41 -0400
In-Reply-To: <1496306615-770-1-git-send-email-markb@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Bloch <markb@mellanox.com>
Date: Thu, 1 Jun 2017 11:43:35 +0300

> Adding a vxlan interface to a socket isn't symmetrical, while adding
> is done in vxlan_open() the deletion is done in vxlan_dellink().
> This can cause a use-after-free error when we close the vxlan
> interface before deleting it.
> 
> We add vxlan_vs_del_dev() to match vxlan_vs_add_dev() and call
> it from vxlan_stop() to match the call from vxlan_open().
> 
> Signed-off-by: Mark Bloch <markb@mellanox.com>

Please add an appropriate Fixes: tag.

Thank you.
