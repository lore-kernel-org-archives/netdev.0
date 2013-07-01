From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH v3] iwl3945: better skb management in rx path
Date: Mon, 1 Jul 2013 14:15:53 +0200
Message-ID: <20130701121552.GA1747@redhat.com>
References: <1372421021.3301.263.camel@edumazet-glaptop>
 <CAMcMvshEdsFZ2PVEpaq0e2P4L+cksshjB56x2YvA4wt3T+3__w@mail.gmail.com>
 <1372431024.3301.277.camel@edumazet-glaptop>
 <1372431906.3301.283.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Stewart <pstew@google.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"Steinar H. Gunderson" <sesse@google.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60996 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752695Ab3GAMNY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Jul 2013 08:13:24 -0400
Content-Disposition: inline
In-Reply-To: <1372431906.3301.283.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 28, 2013 at 08:05:06AM -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Steinar reported reallocations of skb->head with IPv6, leading to
> a warning in skb_try_coalesce()
> 
> It turns out iwl3945 has several problems :
> 
> 1) skb->truesize is underestimated. 
>    We really consume PAGE_SIZE bytes for a fragment,
>    not the frame length.
> 2) 128 bytes of initial headroom is a bit low and forces reallocations.
> 3) We can avoid consuming a full page for small enough frames.
> 
> Reported-by: Steinar H. Gunderson <sesse@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Paul Stewart <pstew@google.com>

Acked-by: Stanislaw Gruszka <sgruszka@redhat.com>

FYI, I'll post 4965 version soon.
