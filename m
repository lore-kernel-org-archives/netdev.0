From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rtnetlink: Add missing manual netlink notification in
 dev_change_net_namespaces
Date: Mon, 24 Oct 2011 03:03:55 -0400 (EDT)
Message-ID: <20111024.030355.1081093788972965128.davem@davemloft.net>
References: <m14o1e71qe.fsf@fess.ebiederm.org>
	<CAChaegnHchLT0BV-_RaPT2-J3ZLin_U1x8X0KBi7ku1MArug1g@mail.gmail.com>
	<m1ty72l3d7.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, equinox@diac24.net,
	renatowestphal@gmail.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41487 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753227Ab1JXHGj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2011 03:06:39 -0400
In-Reply-To: <m1ty72l3d7.fsf_-_@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Fri, 21 Oct 2011 09:24:20 -0700

> Renato Westphal noticed that since commit a2835763e130c343ace5320c20d33c281e7097b7
> "rtnetlink: handle rtnl_link netlink notifications manually" was merged
> we no longer send a netlink message when a networking device is moved
> from one network namespace to another.
> 
> Fix this by adding the missing manual notification in dev_change_net_namespaces.
> 
> Since all network devices that are processed by dev_change_net_namspaces are
> in the initialized state the complicated tests that guard the manual
> rtmsg_ifinfo calls in rollback_registered and register_netdevice are
> unnecessary and we can just perform a plain notification.
> 
> Cc: stable@kernel.org
> Tested-by: Renato Westphal <renatowestphal@gmail.com>
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Applied, thanks Eric.
