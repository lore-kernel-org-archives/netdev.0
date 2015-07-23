From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] ipv6: fix crash over flow-based vxlan device
Date: Thu, 23 Jul 2015 09:17:58 +0200
Message-ID: <20150723071758.GA22790@pox.localdomain>
References: <1437613992-25953-1-git-send-email-weichunc@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, ast@plumgrid.com
To: Wei-Chun Chao <weichunc@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:34670 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751325AbbGWHSB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2015 03:18:01 -0400
Received: by wibud3 with SMTP id ud3so10645437wib.1
        for <netdev@vger.kernel.org>; Thu, 23 Jul 2015 00:18:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1437613992-25953-1-git-send-email-weichunc@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/22/15 at 06:13pm, Wei-Chun Chao wrote:
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

Acked-by: Thomas Graf <tgraf@suug.ch>
