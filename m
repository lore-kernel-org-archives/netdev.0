From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26] [INET]: Remove struct dst_entry *dst from
 request_sock_ops.rtx_syn_ack.
Date: Fri, 29 Feb 2008 11:43:15 -0800 (PST)
Message-ID: <20080229.114315.84886517.davem@davemloft.net>
References: <1204299136-12294-1-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59377
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757102AbYB2TnQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Feb 2008 14:43:16 -0500
In-Reply-To: <1204299136-12294-1-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Fri, 29 Feb 2008 18:32:16 +0300

> It looks like dst parameter is used in this API due to historical reasons.
> Actually, it is really used in the direct call to tcp_v4_send_synack only.
> So, create a wrapper for tcp_v4_send_synack and remove dst from rtx_syn_ack.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Good catch, applied.
