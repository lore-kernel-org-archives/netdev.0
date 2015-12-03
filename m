From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v7] mpls: support for dead routes
Date: Thu, 03 Dec 2015 15:03:52 -0500 (EST)
Message-ID: <20151203.150352.9905176051971327.davem@davemloft.net>
References: <1449037091-12897-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, rshearma@brocade.com, netdev@vger.kernel.org
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45133 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753311AbbLCUDy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 15:03:54 -0500
In-Reply-To: <1449037091-12897-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Date: Tue,  1 Dec 2015 22:18:11 -0800

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> Adds support for RTNH_F_DEAD and RTNH_F_LINKDOWN flags on mpls
> routes due to link events. Also adds code to ignore dead
> routes during route selection.
> 
> Unlike ip routes, mpls routes are not deleted when the route goes
> dead. This is current mpls behaviour and this patch does not change
> that. With this patch however, routes will be marked dead.
> dead routes are not notified to userspace (this is consistent with ipv4
> routes).
 ...
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Applied, thanks so much!
