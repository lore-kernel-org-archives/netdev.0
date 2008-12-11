From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Lockup with tun/tap/bridge interface deregistration.
Date: Thu, 11 Dec 2008 11:02:15 +0000
Message-ID: <20081211110215.GA5910@ff.dom.local>
References: <87fxkwhyyq.fsf@barad-dur.regala.cx> <20081211102421.GB4129@ff.dom.local> <20081211104303.GC4129@ff.dom.local> <20081211104954.GA25179@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mathieu SEGAUD <mathieu.segaud@regala.cx>, netdev@vger.kernel.org,
	kernel@gentoo.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:47276 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755014AbYLKLCW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2008 06:02:22 -0500
Received: by ey-out-2122.google.com with SMTP id 6so164947eyi.37
        for <netdev@vger.kernel.org>; Thu, 11 Dec 2008 03:02:20 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20081211104954.GA25179@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 11, 2008 at 09:49:54PM +1100, Herbert Xu wrote:
...
> Right, this fixes a dead-lock that causes the RTNL to be held which
> doesn't seem to be the case here.  It sounds like the problem in
> this thread is simply due to a non-zero ref count on the netdev
> itself.
> 
> Mathieu, you should get a message like this
> 
> 	unregister_netdevice: waiting for %s to become free. Usage count = %d
> 
> What does your count say?

Right, you can see this at the first link of Mathieu's message:
http://bugs.gentoo.org/attachment.cgi?id=174835&action=view

Jarek P.
