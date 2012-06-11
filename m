From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 2/5] ipv4: Kill ip_rt_frag_needed().
Date: Mon, 11 Jun 2012 13:42:56 +0200
Message-ID: <20120611114256.GL27795@secunet.com>
References: <20120611.022911.885347106959530782.davem@davemloft.net>
 <20120611111659.GK27795@secunet.com>
 <20120611.042024.1022194952800114410.davem@davemloft.net>
 <20120611.042813.401909584318598192.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:32918 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754057Ab2FKLnF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2012 07:43:05 -0400
Content-Disposition: inline
In-Reply-To: <20120611.042813.401909584318598192.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 11, 2012 at 04:28:13AM -0700, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Mon, 11 Jun 2012 04:20:24 -0700 (PDT)
> 
> > We need to find a way to implement this then, in such a way
> > that we have the route context used to send the ping packet
> > out.
> 
> The problem is RAW sockets right?  If so, then this is where the
> fix belongs.
> 

Hm, I've just tried with tracepath (udp) and I also don't see the
pmtu informations cached.

I still had no time to look deeper into the new inetpeer code,
I've just gave it a quick try. I'll try to find out what's going on.
