From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v3] ip_tunnel: Set network header properly for
 IP_ECN_decapsulate()
Date: Mon, 05 May 2014 09:32:51 -0700
Message-ID: <1399307571.2140.16.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1399242005-28999-1-git-send-email-ycai@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Neal Cardwell <ncardwell@google.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Ying Cai <ycai@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:61673 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754339AbaEEQc4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2014 12:32:56 -0400
Received: by mail-pa0-f46.google.com with SMTP id kx10so7161937pab.5
        for <netdev@vger.kernel.org>; Mon, 05 May 2014 09:32:56 -0700 (PDT)
In-Reply-To: <1399242005-28999-1-git-send-email-ycai@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-05-04 at 15:20 -0700, Ying Cai wrote:
> In ip_tunnel_rcv(), set skb->network_header to inner IP header
> before IP_ECN_decapsulate().
> 
> Without the fix, IP_ECN_decapsulate() takes outer IP header as
> inner IP header, possibly causing error messages or packet drops.
> 
> Note that this skb_reset_network_header() call was in this spot when
> the original feature for checking consistency of ECN bits through
> tunnels was added in eccc1bb8d4b4 ("tunnel: drop packet if ECN present
> with not-ECT"). It was only removed from this spot in 3d7b46cd20e3
> ("ip_tunnel: push generic protocol handling to ip_tunnel module.").


Acked-by: Eric Dumazet <edumazet@google.com>
