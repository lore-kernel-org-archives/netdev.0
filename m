From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 0/6][NETNS]: Make ipv6_devconf (all and
 default) live in net namespaces
Date: Thu, 10 Jan 2008 17:54:12 -0800 (PST)
Message-ID: <20080110.175412.104736323.davem@davemloft.net>
References: <478623C0.7030008@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org, dlezcano@fr.ibm.com,
	benjamin.thery@bull.net
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47629
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753461AbYAKByO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 20:54:14 -0500
In-Reply-To: <478623C0.7030008@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Thu, 10 Jan 2008 16:55:12 +0300

> The ipv6_devconf_(all) and ipv6_devconf_dflt are currently
> global, but should be per-namespace.
> 
> This set moves them on the struct net. Or, more precisely,
> on the struct netns_ipv6, which is already added.
> 
> Unfortunately, many code in the ipv6 cannot yet provide a 
> correct struct net to get the ipv6_devconf from (e.g. routing 
> code), so this part of job is to be done after the appropriate 
> parts are virtualized.
> 
> However, after this set user can play with the ipv6_devconf 
> inside a namespace not affecting the others.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

All 6 patches applied, thanks Pavel.
