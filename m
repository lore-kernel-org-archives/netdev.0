From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-2.6.26 1/10][RTNL]: Relax for_each_netdev_safe in
 __rtnl_link_unregister.
Date: Tue, 15 Apr 2008 14:00:02 +0200
Message-ID: <480498C2.3040401@trash.net>
References: <4804989F.1060503@openvz.org> <48049931.9000209@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35191 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751180AbYDOMAH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 08:00:07 -0400
In-Reply-To: <48049931.9000209@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov wrote:
> Each potential list_del (happening from inside a ->dellink call)
> is followed by goto restart, so there's no need in _safe iteration.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Acked-by: Patrick McHardy <kaber@trash.net>
