From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-2.6.25] [MACVLAN] Setting macvlan_handle_frame_hook
 to NULL when rtnl_link_register() fails.
Date: Tue, 29 Jan 2008 16:19:04 +0100
Message-ID: <479F43E8.4010107@trash.net>
References: <eb3ff54b0801290714ja7e7e67t3349028b7db8dc5e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Rami Rosen <ramirose@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57250 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754523AbYA2PTI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2008 10:19:08 -0500
In-Reply-To: <eb3ff54b0801290714ja7e7e67t3349028b7db8dc5e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rami Rosen wrote:
> Hi,
>   In drivers/net/macvlan.c, when rtnl_link_register() fails
> in macvlan_init_module(), there is no point to set it (second time in this
> method) to macvlan_handle_frame; macvlan_init_module() will return a negative
> number, so instead this patch sets macvlan_handle_frame_hook to NULL.


Indeed, that seems to be a stupid cut-and-paste error. Thanks for
catching this.

Dave, please apply.
