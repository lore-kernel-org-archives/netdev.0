From: Willy Tarreau <w@1wt.eu>
Subject: Re: v2.6.25: SKB BUG: Invalid truesize (260) len=134, sizeof(sk_buff)=164
Date: Wed, 14 May 2008 21:55:34 +0200
Message-ID: <20080514195531.GW8474@1wt.eu>
References: <BAY103-DAV9C4667C3BA5764E61DA2CB2CE0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Marco Berizzi <pupilla@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:4312 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762069AbYENTzn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2008 15:55:43 -0400
Content-Disposition: inline
In-Reply-To: <BAY103-DAV9C4667C3BA5764E61DA2CB2CE0@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[CC'd netdev]

On Wed, May 14, 2008 at 05:04:03PM +0200, Marco Berizzi wrote:
> Hi folks.
> After 20 days uptime linux 2.6.25 has
> started logging a ton of these messages:
> 
> May 14 17:00:23 Pleiadi kernel: SKB BUG: Invalid truesize (260) len=134,
> sizeof(sk_buff)=164
> May 14 17:00:23 Pleiadi kernel: SKB BUG: Invalid truesize (260) len=118,
> sizeof(sk_buff)=164
> May 14 17:00:23 Pleiadi kernel: SKB BUG: Invalid truesize (324) len=166,
> sizeof(sk_buff)=164
> May 14 17:00:23 Pleiadi kernel: SKB BUG: Invalid truesize (324) len=166,
> sizeof(sk_buff)=164
> May 14 17:00:23 Pleiadi kernel: SKB BUG: Invalid truesize (260) len=118,
> sizeof(sk_buff)=164
> May 14 17:00:23 Pleiadi kernel: SKB BUG: Invalid truesize (260) len=118,
> sizeof(sk_buff)=164
> May 14 17:00:23 Pleiadi kernel: SKB BUG: Invalid truesize (292) len=166,
> sizeof(sk_buff)=164
> May 14 17:00:23 Pleiadi kernel: SKB BUG: Invalid truesize (324) len=166,
> sizeof(sk_buff)=164
> May 14 17:00:23 Pleiadi kernel: SKB BUG: Invalid truesize (324) len=166,
> sizeof(sk_buff)=164
> May 14 17:00:24 Pleiadi kernel: SKB BUG: Invalid truesize (260) len=118,
> sizeof(sk_buff)=164
> 
> Does it mean there is a problem?

Most likely. I think you'll have to bring your config and a bit of info
about the workload of the machine reporting this.

Willy

