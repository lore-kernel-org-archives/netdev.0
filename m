From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] ipv6: NULL pointer dereferrence in
 tcp_v6_send_ack
Date: Wed, 01 Oct 2008 02:13:42 -0700 (PDT)
Message-ID: <20081001.021342.170858723.davem@davemloft.net>
References: <20081001.020359.48616451.davem@davemloft.net>
	<1222852317-7177-1-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, vgusev@openvz.org, netdev@vger.kernel.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51650
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753132AbYJAJNx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 05:13:53 -0400
In-Reply-To: <1222852317-7177-1-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Wed,  1 Oct 2008 13:11:57 +0400

> The following actions are possible:
> tcp_v6_rcv
>   skb->dev = NULL;
>   tcp_v6_do_rcv
>     tcp_v6_hnd_req
>       tcp_check_req
>         req->rsk_ops->send_ack == tcp_v6_send_ack
> 
> So, skb->dev can be NULL in tcp_v6_send_ack. We must obtain namespace
> from dst entry.
> 
> Thanks to Vitaliy Gusev <vgusev@openvz.org> for initial problem finding
> in IPv4 code.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Applied, thanks for resending this part for me.
