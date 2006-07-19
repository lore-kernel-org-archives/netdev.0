From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Conversions from kmalloc+memset to k(z|c)alloc.
Date: Tue, 18 Jul 2006 21:11:49 -0700 (PDT)
Message-ID: <20060718.211149.132925536.davem@davemloft.net>
References: <20060719010343.GC30823@lumumba.uhasselt.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, acme@conectiva.com.br,
	patrick@tykepenguin.com, per.liden@ericsson.com, mitch@sfgoth.com,
	samuel@sortiz.org, eis@baty.hanse.de, ralf@linux-mips.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:15328
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932489AbWGSELZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jul 2006 00:11:25 -0400
To: takis@lumumba.uhasselt.be
In-Reply-To: <20060719010343.GC30823@lumumba.uhasselt.be>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: takis@lumumba.uhasselt.be (Panagiotis Issaris)
Date: Wed, 19 Jul 2006 03:03:43 +0200

> From: Panagiotis Issaris <takis@issaris.org>
> 
> net: Conversions from kmalloc+memset to kzalloc.
> 
> Signed-off-by: Panagiotis Issaris <takis@issaris.org>

Applied, thanks a lot.

One of the ieee80211 cases is even a bug fix because it
was memset()'ing without checking if kmalloc() returned
NULL.
