From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: linux-3.0.x regression with ipv4 routes having mtu
Date: Thu, 2 Feb 2012 11:01:40 +0100
Message-ID: <20120202100140.GB23142@secunet.com>
References: <20111220071843.GL6348@secunet.com>
 <20111220.133542.2144336048061483258.davem@davemloft.net>
 <20111221085616.GO6348@secunet.com>
 <20111221.155615.990885397853981125.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:48536 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753689Ab2BBKBr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Feb 2012 05:01:47 -0500
Content-Disposition: inline
In-Reply-To: <20111221.155615.990885397853981125.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 21, 2011 at 03:56:15PM -0500, David Miller wrote:
> 
> Ok, so what you're saying is that we need a way to invalidate inetpeer
> entries, or at least invalidate their cached metrics and set
> INETPEER_METRICS_NEW once more.

In between I tried the approach to invalidate the cached metrics.
Unfortunately, we we can not just set INETPEER_METRICS_NEW once
again and overwrite the existing metrics once the inetpeer
is public. This would require some kind of locking, so I tried
a rcu based approach.

I'll send the patches for review in a new thread.
