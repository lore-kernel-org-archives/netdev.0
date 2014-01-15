From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2 2/2] net: Check skb->rxhash in gro_receive
Date: Tue, 14 Jan 2014 16:20:26 -0800
Message-ID: <1389745226.31367.290.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.02.1401141555560.25161@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f179.google.com ([209.85.161.179]:44011 "EHLO
	mail-gg0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751499AbaAOAUa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 19:20:30 -0500
Received: by mail-gg0-f179.google.com with SMTP id e5so310933ggh.24
        for <netdev@vger.kernel.org>; Tue, 14 Jan 2014 16:20:29 -0800 (PST)
In-Reply-To: <alpine.DEB.2.02.1401141555560.25161@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-01-14 at 16:02 -0800, Tom Herbert wrote:
> When initializing a gro_list for a packet, first check the rxhash of
> the incoming skb against that of the skb's in the list. This should be
> a very strong inidicator of whether the flow is going to be matched,
> and potentially allows a lot of other checks to be short circuited.
> Use skb_hash_noeval so that we don't force the hash to be calculated.
> 
> Tested by running netperf 200 TCP_STREAMs between two machines with
> GRO, HW rxhash, and 1G. Saw no performance degration, slight reduction
> of time in dev_gro_receive.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  net/core/dev.c | 9 ++++++++-
>  1 file changed, 8 insertions(+), 1 deletion(-)

Acked-by: Eric Dumazet <edumazet@google.com>
