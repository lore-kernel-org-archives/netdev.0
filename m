From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] igmp: fix ip_mc_sf_allow race [v5]
Date: Tue, 02 Feb 2010 07:32:39 -0800 (PST)
Message-ID: <20100202.073239.209986619.davem@davemloft.net>
References: <4B42E252.1080405@gmail.com>
	<1262724742-5232-1-git-send-email-fleitner@redhat.com>
	<20100128161338.GB3544@sysclose.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dlstevens@us.ibm.com,
	eric.dumazet@gmail.com
To: fbl@sysclose.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45609
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756359Ab0BBPc1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2010 10:32:27 -0500
In-Reply-To: <20100128161338.GB3544@sysclose.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Flavio Leitner <fbl@sysclose.org>
Date: Thu, 28 Jan 2010 14:13:38 -0200

> Hello,
> 
> This is another version considering the suggestions. Thanks!
> I didn't convert to list_head yet because a lot more code needs
> to be changed so I'd rather leave that to another patch.
> 8<---------
> 
> Almost all igmp functions accessing inet->mc_list are protected by
> rtnl_lock(), but there is one exception which is ip_mc_sf_allow(),
> so there is a chance of either ip_mc_drop_socket or ip_mc_leave_group
> remove an entry while ip_mc_sf_allow is running causing a crash.
> 
> Signed-off-by: Flavio Leitner <fleitner@redhat.com>

Applied to net-next-2.6, thanks.
