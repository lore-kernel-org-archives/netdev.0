From: David Miller <davem@davemloft.net>
Subject: Re: physmap and "request_module: runaway loop modprobe net-pf-1"
Date: Wed, 23 Apr 2008 23:10:55 -0700 (PDT)
Message-ID: <20080423.231055.193687131.davem@davemloft.net>
References: <1208867831.9212.582.camel@pmac.infradead.org>
	<97a0a9ac0804232101i71bfff22o723e2aaa80b09c2f@mail.gmail.com>
	<1209016143.9212.910.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gordonfarquharson@gmail.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, linux-mtd@lists.infradead.org,
	netdev@vger.kernel.org
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34762
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752308AbYDXGKy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 02:10:54 -0400
In-Reply-To: <1209016143.9212.910.camel@pmac.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <dwmw2@infradead.org>
Date: Thu, 24 Apr 2008 06:49:03 +0100

> On Wed, 2008-04-23 at 22:01 -0600, Gordon Farquharson wrote:
> > I guess the question is which patch (if either) is more appealing.
> 
> I definitely think we should initialise AF_UNIX sockets earlier. At
> least request_module() _can_ work then, if you want it to and you set up
> userspace accordingly.

I'm not so sure, for example, what if AF_UNIX is built modular?
