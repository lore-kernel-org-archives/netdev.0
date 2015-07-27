From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: fix crash over flow-based vxlan device
Date: Sun, 26 Jul 2015 20:55:14 -0700 (PDT)
Message-ID: <20150726.205514.377285318773173282.davem@davemloft.net>
References: <1437613992-25953-1-git-send-email-weichunc@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@plumgrid.com, tgraf@suug.ch
To: weichunc@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37812 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755419AbbG0DzP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jul 2015 23:55:15 -0400
In-Reply-To: <1437613992-25953-1-git-send-email-weichunc@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei-Chun Chao <weichunc@plumgrid.com>
Date: Wed, 22 Jul 2015 18:13:12 -0700

> Similar check was added in ip_rcv but not in ipv6_rcv.
> 
> BUG: unable to handle kernel NULL pointer dereference at (null)
> IP: [<ffffffff81734e0a>] ipv6_rcv+0xfa/0x500
> Call Trace:
> [<ffffffff816c9786>] ? ip_rcv+0x296/0x400
> [<ffffffff817732d2>] ? packet_rcv+0x52/0x410
> [<ffffffff8168e99f>] __netif_receive_skb_core+0x63f/0x9a0
> [<ffffffffc02b34a0>] ? br_handle_frame_finish+0x580/0x580 [bridge]
> [<ffffffff8109912c>] ? update_rq_clock.part.81+0x1c/0x40
> [<ffffffff8168ed18>] __netif_receive_skb+0x18/0x60
> [<ffffffff8168fa1f>] process_backlog+0x9f/0x150
> 
> Fixes: ee122c79d422 (vxlan: Flow based tunneling)
> Signed-off-by: Wei-Chun Chao <weichunc@plumgrid.com>

Applied, thank you.
