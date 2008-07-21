From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [GIT]: Networking
Date: Mon, 21 Jul 2008 05:22:26 +0400
Message-ID: <20080721012225.GA4808@martell.zuzino.mipt.ru>
References: <alpine.LFD.1.10.0807201751440.31863@woody.linux-foundation.org> <20080720.180304.51601407.davem@davemloft.net> <20080721010952.GA4822@martell.zuzino.mipt.ru> <20080720.181440.122144107.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:17709 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754385AbYGUBYh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jul 2008 21:24:37 -0400
Received: by ug-out-1314.google.com with SMTP id h2so203831ugf.16
        for <netdev@vger.kernel.org>; Sun, 20 Jul 2008 18:24:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080720.181440.122144107.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 20, 2008 at 06:14:40PM -0700, David Miller wrote:
> > And finally, boot process hangs after TCP cubic is initialized.
> 
> That very much should not happen.  Can you turn on initcall
> tracing so we can see where that is happening exactly?

Before that BUG_ON in __netif_schedule() happens (and quickly scrolls
off). But after netconsole ups device (which is ATL1 if it matters).

