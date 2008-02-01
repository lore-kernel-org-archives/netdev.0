From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25] [MACVLAN] Setting macvlan_handle_frame_hook
 to NULL when rtnl_link_register() fails.
Date: Thu, 31 Jan 2008 16:56:11 -0800 (PST)
Message-ID: <20080131.165611.218969790.davem@davemloft.net>
References: <eb3ff54b0801290714ja7e7e67t3349028b7db8dc5e@mail.gmail.com>
	<479F43E8.4010107@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ramirose@gmail.com, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50157
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752120AbYBAAzu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 19:55:50 -0500
In-Reply-To: <479F43E8.4010107@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 29 Jan 2008 16:19:04 +0100

> Rami Rosen wrote:
> > Hi,
> >   In drivers/net/macvlan.c, when rtnl_link_register() fails
> > in macvlan_init_module(), there is no point to set it (second time in this
> > method) to macvlan_handle_frame; macvlan_init_module() will return a negative
> > number, so instead this patch sets macvlan_handle_frame_hook to NULL.
> 
> 
> Indeed, that seems to be a stupid cut-and-paste error. Thanks for
> catching this.
> 
> Dave, please apply.

Done.
