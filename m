From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 11/12 net-2.6.25] [NETNS]: Routing cache virtualization.
Date: Tue, 22 Jan 2008 23:51:23 -0800 (PST)
Message-ID: <20080122.235123.197893963.davem@davemloft.net>
References: <479612BE.8030409@openvz.org>
	<1201074387-7366-2-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org, containers@lists.osdl.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41108
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752956AbYAWHvP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 02:51:15 -0500
In-Reply-To: <1201074387-7366-2-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Wed, 23 Jan 2008 10:46:26 +0300

> Basically, this piece looks relatively easy. Namespace is already available
> on the dst entry via device and the device is safe to dereferrence. Compare
> it with one of a searcher and skip entry if appropriate.
> 
> The only exception is ip_rt_frag_needed. So, add namespace parameter to it.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Applied.
