From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/6][NETNS]: Tcp-v4 sockets per-net lookup.
Date: Thu, 31 Jan 2008 05:06:51 -0800 (PST)
Message-ID: <20080131.050651.253996523.davem@davemloft.net>
References: <47A1C137.4030306@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40380
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1761300AbYAaNGa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 08:06:30 -0500
In-Reply-To: <47A1C137.4030306@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Thu, 31 Jan 2008 15:38:15 +0300

> Add a net argument to inet_lookup and propagate it further
> into lookup calls. Plus tune the __inet_check_established.
> 
> The dccp and inet_diag, which use that lookup functions
> pass the init_net into them.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
