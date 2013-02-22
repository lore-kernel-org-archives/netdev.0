From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: use a stronger hash for tcp
Date: Fri, 22 Feb 2013 01:14:53 +0100
Message-ID: <20130222001453.GC9671@order.stressinduktion.org>
References: <1361485132.17413.19.camel@edumazet-glaptop> <20130221.181822.1234155083700257175.davem@davemloft.net> <m2fw0pxm6b.fsf@firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, ncardwell@google.com, ycheng@google.com
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:49439 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753504Ab3BVAOy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2013 19:14:54 -0500
Content-Disposition: inline
In-Reply-To: <m2fw0pxm6b.fsf@firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 21, 2013 at 03:49:16PM -0800, Andi Kleen wrote:
> David Miller <davem@davemloft.net> writes:
> >
> > I bet we can consolidate this slightly, to make it less
> > expensive yet not give up much in terms of protection.  Two
> > jhash3word()'s is quite a lot.
> 
> jhash is not really the state of the art for general hashing anymore,
> murmur3 or cityhash are generally considered faster/possibly better.

murmur3 and cityhash are broken in terms of collision resistance.  I have
not heard anything about jenkins being affected (but have not searched
either). SipHash is a relativly new hash function specifically designed
to protect against hashdos, but I fear it could be more expansive for very
small inputs: https://131002.net/siphash/

Greetings,

  Hannes
