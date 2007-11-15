From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][NET-2.6.25] Move sock_valbool_flag to socket.c
Date: Thu, 15 Nov 2007 03:03:41 -0800 (PST)
Message-ID: <20071115.030341.157713935.davem@davemloft.net>
References: <473C14D7.80008@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44518
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1765006AbXKOLDm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 06:03:42 -0500
In-Reply-To: <473C14D7.80008@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Thu, 15 Nov 2007 12:43:51 +0300

> The sock_valbool_flag() helper is used in setsockopt to 
> set or reset some flag on the sock. This helper is required
> in the net/socket.c only, so move it there.
> 
> Besides, patch two places in sys_setsockopt() that repeat
> this helper functionality manually.
> 
> Since this is not a bugfix, but a trivial cleanup, I
> prepared this patch against net-2.6.25, but it also
> applies (with a single offset) to the latest net-2.6.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied to net-2.6.25, thanks Pavel.
