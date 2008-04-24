From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: physmap and "request_module: runaway loop modprobe net-pf-1"
Date: Thu, 24 Apr 2008 08:16:39 +0100
Message-ID: <1209021399.9212.927.camel@pmac.infradead.org>
References: <1208867831.9212.582.camel@pmac.infradead.org>
	 <97a0a9ac0804232101i71bfff22o723e2aaa80b09c2f@mail.gmail.com>
	 <1209016143.9212.910.camel@pmac.infradead.org>
	 <20080423.231055.193687131.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: gordonfarquharson@gmail.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, linux-mtd@lists.infradead.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:32986 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750776AbYDXHRA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 03:17:00 -0400
In-Reply-To: <20080423.231055.193687131.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-04-23 at 23:10 -0700, David Miller wrote:
> From: David Woodhouse <dwmw2@infradead.org>
> Date: Thu, 24 Apr 2008 06:49:03 +0100
> 
> > On Wed, 2008-04-23 at 22:01 -0600, Gordon Farquharson wrote:
> > > I guess the question is which patch (if either) is more appealing.
> > 
> > I definitely think we should initialise AF_UNIX sockets earlier. At
> > least request_module() _can_ work then, if you want it to and you set up
> > userspace accordingly.
> 
> I'm not so sure, for example, what if AF_UNIX is built modular?

I believe that as long as you include it in your initrd, it'll get
loaded on demand and all will be well. The first request_module() call
will trigger a request_module(af_unix), which will succeed.

-- 
dwmw2

