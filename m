From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] flowcache: Increase threshold for refusing new
 allocations
Date: Wed, 23 Nov 2016 13:42:55 +0100
Message-ID: <20161123124255.GA3541@gauss.secunet.com>
References: <20161121144820.GA4048@miroslavurbanek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: NetDev <netdev@vger.kernel.org>
To: Miroslav Urbanek <mu@miroslavurbanek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:57133 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S936026AbcKWMnK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 23 Nov 2016 07:43:10 -0500
Content-Disposition: inline
In-Reply-To: <20161121144820.GA4048@miroslavurbanek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 21, 2016 at 03:48:21PM +0100, Miroslav Urbanek wrote:
> The threshold for OOM protection is too small for systems with large
> number of CPUs. Applications report ENOBUFs on connect() every 10
> minutes.
> 
> The problem is that the variable net->xfrm.flow_cache_gc_count is a
> global counter while the variable fc->high_watermark is a per-CPU
> constant. Take the number of CPUs into account as well.
> 
> Fixes: 6ad3122a08e3 ("flowcache: Avoid OOM condition under preasure")
> Reported-by: Lukáš Koldrt <lk@excello.cz>
> Tested-by: Jan Hejl <jh@excello.cz>
> Signed-off-by: Miroslav Urbanek <mu@miroslavurbanek.com>

Applied to the ipsec tree, thanks!
