From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25] Cleanup sysctl manipulations in devinet.c
Date: Tue, 11 Dec 2007 02:17:54 -0800 (PST)
Message-ID: <20071211.021754.31077873.davem@davemloft.net>
References: <47597417.9090801@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51042
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751187AbXLKKRz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 05:17:55 -0500
In-Reply-To: <47597417.9090801@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Fri, 07 Dec 2007 19:25:59 +0300

> This includes:
> 
>  * moving neigh_sysctl_(un)register calls inside
>    devinet_sysctl_(un)register ones, as they are always
>    called in pairs;
>  * making __devinet_sysctl_unregister() to unregister
>    the ipv4_devconf struct, while original devinet_sysctl_unregister()
>    works with the in_device to handle both - devconf and
>    neigh sysctls;
>  * make stubs for CONFIG_SYSCTL=n case to get rid of
>    in-code ifdefs.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied, thanks!
