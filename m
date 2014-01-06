From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next 1/2] ipv4: add forwarding_uses_pmtu knob to
 protect forward path to use pmtu info
Date: Mon, 6 Jan 2014 14:18:22 +0100
Message-ID: <20140106131822.GU31491@secunet.com>
References: <20131220130822.GD32129@order.stressinduktion.org>
 <20131231042840.GC27636@order.stressinduktion.org>
 <20140106090521.GQ31491@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org, eric.dumazet@gmail.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:48951 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751335AbaAFNSZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jan 2014 08:18:25 -0500
Content-Disposition: inline
In-Reply-To: <20140106090521.GQ31491@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 06, 2014 at 10:05:21AM +0100, Steffen Klassert wrote:
> > 
> > IIRC you have a (semi-)automatic test suite to test for (p)mtu problems? Would
> > these checks cover such a change?
> > 
> 
> I'm currenlty testing these patches. ipv4 looks good but on
> ipv6 with 'ping6' the packet size is not reduced according
> to the pmtu when forward_use_pmtu is set to 0.
> 
> I'll run the tests again with your updated v3 patches.
> 

The v3 version of your patches don't show any obvious regressions
on our pmtu test suite.
