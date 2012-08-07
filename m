From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: force dst_default_metrics to const section
Date: Tue, 07 Aug 2012 16:17:57 -0700 (PDT)
Message-ID: <20120807.161757.1233303983113040933.davem@davemloft.net>
References: <1344378854.28967.201.camel@edumazet-glaptop>
	<1344379474.2688.89.camel@bwh-desktop.uk.solarflarecom.com>
	<1344380200.28967.207.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34109 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757062Ab2HGXSL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2012 19:18:11 -0400
In-Reply-To: <1344380200.28967.207.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 08 Aug 2012 00:56:40 +0200

> On Tue, 2012-08-07 at 23:44 +0100, Ben Hutchings wrote:
> 
>> Any consideration of implementation details like BSS and cache line
>> sharing is already outside of 'plain C'.  And you don't have to 'mess
>> with all arches'; just look at what <linux/init.h> and <linux/module.h>
>> do.
> 
> "const" is the clean and portable way to express my needs. No magic
> section.
> 
> All is self-contained in the definition of the metrics, with a nice
> comment.
> 
> All const are naturally shared by all cpus, without adding extra cache
> line boundaries.

I agree with Eric and will apply his patch.
