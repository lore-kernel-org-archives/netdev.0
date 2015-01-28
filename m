From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vxlan: advertise link netns in fdb messages
Date: Tue, 27 Jan 2015 17:11:46 -0800 (PST)
Message-ID: <20150127.171146.1854293554835563854.davem@davemloft.net>
References: <1422277853-5722-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54193 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753230AbbA1BLr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 20:11:47 -0500
In-Reply-To: <1422277853-5722-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Mon, 26 Jan 2015 14:10:53 +0100

> Previous commit is based on a wrong assumption, fdb messages are always sent
> into the netns where the interface stands (see vxlan_fdb_notify()).
> 
> These fdb messages doesn't embed the rtnl attribute IFLA_LINK_NETNSID, thus we
> need to add it (useful to interpret NDA_IFINDEX or NDA_DST for example).
> 
> Note also that vxlan_nlmsg_size() was not updated.
> 
> Fixes: 193523bf9373 ("vxlan: advertise netns of vxlan dev in fdb msg")
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied.
