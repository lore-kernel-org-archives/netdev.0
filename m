From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3][UNIX] Convert socks to unix_socks in
 scan_inflight, not in callbacks
Date: Sat, 10 Nov 2007 22:07:23 -0800 (PST)
Message-ID: <20071110.220723.226154590.davem@davemloft.net>
References: <4731C405.6010203@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58073
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752218AbXKKGHY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Nov 2007 01:07:24 -0500
In-Reply-To: <4731C405.6010203@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Wed, 07 Nov 2007 16:56:21 +0300

> The scan_inflight() routine scans through the unix sockets and calls
> some passed callback. The fact is that all these callbacks work with
> the unix_sock objects, not the sock ones, so make this conversion in
> the scan_inflight() before calling the callbacks.
> 
> This removes one unneeded variable from the inc_inflight_move_tail().
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied, thanks Pavel.
