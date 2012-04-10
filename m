From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 04/10] net: pad skb data and shinfo as a whole rather
 than individually
Date: Tue, 10 Apr 2012 17:01:30 +0200
Message-ID: <1334070090.5300.59.camel@edumazet-glaptop>
References: <1334067965.5394.22.camel@zakaz.uk.xensource.com>
	 <1334067984-7706-4-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Wei Liu <wei.liu2@citrix.com>, xen-devel@lists.xen.org
To: Ian Campbell <ian.campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:41746 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758897Ab2DJPBk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 11:01:40 -0400
Received: by bkcik5 with SMTP id ik5so4305694bkc.19
        for <netdev@vger.kernel.org>; Tue, 10 Apr 2012 08:01:39 -0700 (PDT)
In-Reply-To: <1334067984-7706-4-git-send-email-ian.campbell@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-04-10 at 15:26 +0100, Ian Campbell wrote:
> This reduces the minimum overhead required for this allocation such that the
> shinfo can be grown in the following patch without overflowing 2048 bytes for a
> 1500 byte frame.
> 
> Reducing this overhead while also growing the shinfo means that sometimes the
> tail end of the data can end up in the same cache line as the beginning of the
> shinfo. Specifically in the case of the 64 byte cache lines on a 64 bit system
> the first 8 bytes of shinfo can overlap the tail cacheline of the data. In many
> cases the allocation slop means that there is no overlap.
> 
> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> ---

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
