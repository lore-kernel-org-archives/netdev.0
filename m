From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 01/10] net: add and use SKB_ALLOCSIZE
Date: Tue, 10 Apr 2012 16:57:41 +0200
Message-ID: <1334069861.5300.52.camel@edumazet-glaptop>
References: <1334067965.5394.22.camel@zakaz.uk.xensource.com>
	 <1334067984-7706-1-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Wei Liu <wei.liu2@citrix.com>, xen-devel@lists.xen.org
To: Ian Campbell <ian.campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:37339 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758806Ab2DJO5r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 10:57:47 -0400
Received: by bkcik5 with SMTP id ik5so4301378bkc.19
        for <netdev@vger.kernel.org>; Tue, 10 Apr 2012 07:57:45 -0700 (PDT)
In-Reply-To: <1334067984-7706-1-git-send-email-ian.campbell@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-04-10 at 15:26 +0100, Ian Campbell wrote:
> This gives the allocation size required for an skb containing X bytes of data
> 
> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> ---
>  drivers/net/ethernet/broadcom/bnx2.c        |    7 +++----
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x.h |    3 +--
>  drivers/net/ethernet/broadcom/tg3.c         |    3 +--
>  include/linux/skbuff.h                      |   12 ++++++++++++
>  net/core/skbuff.c                           |    8 +-------
>  5 files changed, 18 insertions(+), 15 deletions(-)
> 

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
