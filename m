From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] ip: NULL pointer dereferrence in
 tcp_v(4|6)_send_ack
Date: Wed, 01 Oct 2008 01:52:46 -0700 (PDT)
Message-ID: <20081001.015246.92774687.davem@davemloft.net>
References: <200809302013.30051.vgusev@openvz.org>
	<1222792151-11861-1-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, vgusev@openvz.org, netdev@vger.kernel.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59943
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751982AbYJAIw6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 04:52:58 -0400
In-Reply-To: <1222792151-11861-1-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Tue, 30 Sep 2008 20:29:11 +0400

> The following actions are possible:
> tcp_v4_rcv
>   skb->dev = NULL;
>   tcp_v4_do_rcv
>     tcp_v4_hnd_req
>       tcp_check_req
>         req->rsk_ops->send_ack == tcp_v4_send_ack
> 
> So, skb->dev can be NULL in tcp_v4_send_ack. We must obtain namespace
> from dst entry. IPv6 codepath is similar.
> 
> Thanks to Vitaliy Gusev <vgusev@openvz.org> for initial oops decoding.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Vitaliy sent the same patch first, so I applied his copy :-)

Thanks everyone.
