From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: force dst_default_metrics to const section
Date: Wed, 08 Aug 2012 00:56:40 +0200
Message-ID: <1344380200.28967.207.camel@edumazet-glaptop>
References: <1344355878.28967.113.camel@edumazet-glaptop>
	 <1344370527.2688.61.camel@bwh-desktop.uk.solarflarecom.com>
	 <1344372945.28967.165.camel@edumazet-glaptop>
	 <1344377561.2688.66.camel@bwh-desktop.uk.solarflarecom.com>
	 <1344378854.28967.201.camel@edumazet-glaptop>
	 <1344379474.2688.89.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:60302 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031222Ab2HGW4p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2012 18:56:45 -0400
Received: by wgbfm10 with SMTP id fm10so2802627wgb.1
        for <netdev@vger.kernel.org>; Tue, 07 Aug 2012 15:56:43 -0700 (PDT)
In-Reply-To: <1344379474.2688.89.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-08-07 at 23:44 +0100, Ben Hutchings wrote:

> Any consideration of implementation details like BSS and cache line
> sharing is already outside of 'plain C'.  And you don't have to 'mess
> with all arches'; just look at what <linux/init.h> and <linux/module.h>
> do.

"const" is the clean and portable way to express my needs. No magic
section.

All is self-contained in the definition of the metrics, with a nice
comment.

All const are naturally shared by all cpus, without adding extra cache
line boundaries.

Please feel free to send another version, but I wont spend more time
myself.

Thanks
