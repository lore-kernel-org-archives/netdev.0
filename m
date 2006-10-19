From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NET] reduce per cpu ram used for loopback stats
Date: Wed, 18 Oct 2006 20:53:23 -0700 (PDT)
Message-ID: <20061018.205323.78494380.davem@davemloft.net>
References: <200610171458.37636.dada1@cosmosbay.com>
	<200610180938.39175.dada1@cosmosbay.com>
	<200610181835.48744.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:11435
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1423246AbWJSDxO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Oct 2006 23:53:14 -0400
To: dada1@cosmosbay.com
In-Reply-To: <200610181835.48744.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 18 Oct 2006 18:35:48 +0200

Applied Eric, but the file paths in your patch were bogus and needed
to be fixed up:

> --- linux/drivers/net/loopback.c	2006-10-18 17:28:20.000000000 +0200
> +++ linux-eddrivers/net/loopback.c	2006-10-18 18:26:41.000000000 +0200

This would never apply, since "-p1" patch treatment would use
"net/loopback.c" as the patch which is obviously wrong and should be
"drivers/net/loopback.c"

I don't know what you use to generate patches, but you might stand to
gain from using some automated tools for this :-)
