From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: physmap and "request_module: runaway loop modprobe net-pf-1"
Date: Thu, 24 Apr 2008 08:24:12 +0100
Message-ID: <1209021852.9212.936.camel@pmac.infradead.org>
References: <1209016143.9212.910.camel@pmac.infradead.org>
	 <20080423.231055.193687131.davem@davemloft.net>
	 <1209021399.9212.927.camel@pmac.infradead.org>
	 <20080424.002038.201593352.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: gordonfarquharson@gmail.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, linux-mtd@lists.infradead.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:40044 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750902AbYDXHYR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 03:24:17 -0400
In-Reply-To: <20080424.002038.201593352.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-04-24 at 00:20 -0700, David Miller wrote:
> But won't the request_module() for AF_UNIX spit out that warning too?

Yes. If you build AF_UNIX as a module, it will. Just once though, before
loading it (assuming it's available).

> Actually, I think I need a clarification.  It is the modular loader
> utility in userspace which is trying to open up AF_UNIX sockets,
> right?

Yes. Or probably libc.

-- 
dwmw2

