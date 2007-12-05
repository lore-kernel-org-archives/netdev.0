From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 11/11][IPV6] Eliminate difference in actions
 of sysctl and proc handler for conf.all.forwarding
Date: Wed, 05 Dec 2007 01:51:05 -0800 (PST)
Message-ID: <20071205.015105.110790116.davem@davemloft.net>
References: <4755256F.9000505@openvz.org>
	<475529A0.4010300@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58619
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751296AbXLEJvK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 04:51:10 -0500
In-Reply-To: <475529A0.4010300@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 04 Dec 2007 13:19:12 +0300

> The only difference in this case is that updating all.forwarding
> causes the update in default.forwarding when done via proc, but
> not via the system call.
> 
> Besides, this consolidates a good portion of code.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

This is another case where I think we should do what
the procfs case was doing, because that's what people
expect at this point.

That seems to be what your patch is doing, so I'll
apply this, thanks.
