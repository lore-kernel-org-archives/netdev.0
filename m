From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: fix kernel panic from no dev->hard_header_len
 space
Date: Mon, 31 Jul 2006 13:24:34 -0700 (PDT)
Message-ID: <20060731.132434.88476833.davem@davemloft.net>
References: <20060730.153004.45876935.davem@davemloft.net>
	<20060731153948.GB17540@ms2.inr.ac.ru>
	<m3r701zgku.fsf@defiant.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:4842
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932518AbWGaUYk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jul 2006 16:24:40 -0400
To: khc@pm.waw.pl
In-Reply-To: <m3r701zgku.fsf@defiant.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Krzysztof Halasa <khc@pm.waw.pl>
Date: Mon, 31 Jul 2006 22:04:33 +0200

> This is non-trivial because hard_header and hard_start_xmit
> functions currently can't return new skb address (hard_header()
> can't use skb_realloc_headroom() at all, xmit() can't use it if
> there is a need to requeue the packet).
> 
> Or can you just realloc the data portion of skb without changing skb
> struct address? The skb may be referenced by other things.

Krzysztof, which device driver exactly creates this problem
in the first place?
