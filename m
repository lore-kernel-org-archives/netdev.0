From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 5/7] Move the devinet pointers on the struct
 net
Date: Sun, 16 Dec 2007 13:31:56 -0800 (PST)
Message-ID: <20071216.133156.263477544.davem@davemloft.net>
References: <475ECC69.1040809@openvz.org>
	<475ECF7E.2060103@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.osdl.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48839
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758909AbXLPVcG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2007 16:32:06 -0500
In-Reply-To: <475ECF7E.2060103@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 11 Dec 2007 20:57:18 +0300

> This is the core.
> 
> Add all and default pointers on the netns_ipv4 and register
> a new pernet subsys to initialize them.
> 
> Also add the ctl_table_header to register the 
> net.ipv4.ip_forward ctl.
> 
> I don't allocate additional memory for init_net, but use
> global devinets.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
