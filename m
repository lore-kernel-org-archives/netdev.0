From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Don't limit the number of tunnels with generic name
 explicitly.
Date: Sat, 23 Feb 2008 20:20:21 -0800 (PST)
Message-ID: <20080223.202021.191612366.davem@davemloft.net>
References: <47BD6BD7.1060200@openvz.org>
	<47BD6CE9.7000908@trash.net>
	<47BD70B8.3030507@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48663
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753316AbYBXETk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Feb 2008 23:19:40 -0500
In-Reply-To: <47BD70B8.3030507@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Thu, 21 Feb 2008 15:38:16 +0300

> Changelog:
> 
> Use the added dev_alloc_name() call to create tunnel device name,
> rather than iterate in a hand-made loop with an artificial limit.
> 
> Thanks Patrick for noticing this.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied, but I had to rework this in two places that didn't
apply cleanly.

The ip_gre.c and ipip.c changes remove a "failed" label but
that can't be done in the current tree as there are other
existing references.
