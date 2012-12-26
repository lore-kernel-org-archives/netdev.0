From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/vxlan: Use the underlying device index when
 joining/leaving multicast groups
Date: Wed, 26 Dec 2012 15:10:12 -0800 (PST)
Message-ID: <20121226.151012.641411607183357552.davem@davemloft.net>
References: <1356010568-21644-1-git-send-email-yanb@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org,
	ogerlitz@mellanox.com
To: yanb@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36011 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751371Ab2LZXKM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Dec 2012 18:10:12 -0500
In-Reply-To: <1356010568-21644-1-git-send-email-yanb@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yan Burman <yanb@mellanox.com>
Date: Thu, 20 Dec 2012 15:36:08 +0200

> The socket calls from vxlan to join/leave multicast group aren't
> using the index of the underlying device, as a result the stack uses
> the first interface that is up. This results in vxlan being non functional
> over a device which isn't the 1st to be up.
> Fix this by providing the iflink field to the vxlan instance
> to the multicast calls.
> 
> Signed-off-by: Yan Burman <yanb@mellanox.com>

Applied, thanks.
