From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] Un-define the IPTUNNEL_XMIT() macro
Date: Sat, 10 Nov 2007 21:42:28 -0800 (PST)
Message-ID: <20071110.214228.117912463.davem@davemloft.net>
References: <47345C26.3010502@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51012
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751080AbXKKFm3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Nov 2007 00:42:29 -0500
In-Reply-To: <47345C26.3010502@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Fri, 09 Nov 2007 16:09:58 +0300

> This one is used in all the smth-to-ip tunnels we have and
> looks ... not very good. Make this a regular function in the
> tunnel4.ko module.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

This breaks the build if NET_IPGRE is selected, and I don't think it's
wise to add the dependency on INET_TUNNEL just for this one function.
