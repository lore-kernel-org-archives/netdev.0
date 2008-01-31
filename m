From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25][NETNS]: Fix race between put_net() and
 netlink_kernel_create().
Date: Wed, 30 Jan 2008 19:31:28 -0800 (PST)
Message-ID: <20080130.193128.136832319.davem@davemloft.net>
References: <47988F61.9070505@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: den@openvz.org, netdev@vger.kernel.org, devel@openvz.org,
	adobriyan@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49624
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752113AbYAaDbI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 22:31:08 -0500
In-Reply-To: <47988F61.9070505@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Thu, 24 Jan 2008 16:15:13 +0300

> The comment about "race free view of the set of network 
> namespaces" was a bit hasty. Look (there even can be only 
> one CPU, as discovered by Alexey Dobriyan and Denis Lunev):
 ...
> Instead, I propose to crate the socket inside an init_net
> namespace and then re-attach it to the desired one right
> after the socket is created.
> 
> After doing this, we also have to be careful on error paths
> not to drop the reference on the namespace, we didn't get
> the one on.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> Acked-by: Denis Lunev <den@openvz.org>

Applied, thanks.
