From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [PATCH] IPv6: NLM_F_* flag support for route creation/changing when using netlink.
Date: Thu, 27 Oct 2011 00:12:23 -0700 (PDT)
Message-ID: <9b43e0ef-21cf-4062-b998-849e9e8d6b56@tahiti.vyatta.com>
References: <20111027.030658.1922451477684539766.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	matti vaittinen ext <matti.vaittinen.ext@nsn.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51670 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753381Ab1J0HMZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Oct 2011 03:12:25 -0400
In-Reply-To: <20111027.030658.1922451477684539766.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> From: "Vaittinen, Matti (EXT-Other - FI/Oulu)"
> <matti.vaittinen.ext@nsn.com>
> Date: Thu, 27 Oct 2011 09:26:05 +0300
> 
> > 
> > Will requiring NLM_F_CREATE break lots of existing userspace
> > software?
> 
> I can almost guarenetee that since we haven't been requiring this,
> it will break almost everything.

Why not just make it a kernel warning for several releases.

Just checked, and iproute and quagga will have no problem since
they both already pass the CREATE flag.
