From: Jamie Gloudon <jamie.gloudon@gmail.com>
Subject: Re: [PATCH net-next] via-rhine: add 64bit statistics.
Date: Wed, 23 Jan 2013 20:34:27 -0400
Message-ID: <5100819b.2605650a.1e3b.ffffe312@mx.google.com>
References: <50fff42d.094e640a.3ace.6ae4@mx.google.com>
 <1358951884.12374.790.camel@edumazet-glaptop>
 <510004a3.2444ec0a.1ba7.ffff98b3@mx.google.com>
 <1358957838.12374.805.camel@edumazet-glaptop>
 <5100786f.04bc650a.65b3.fffffd3d@mx.google.com>
 <1358985772.12374.1250.camel@edumazet-glaptop>
 <51007e6c.4170ec0a.7218.18c2@mx.google.com>
 <1358987262.12374.1283.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ye0-f169.google.com ([209.85.213.169]:44044 "EHLO
	mail-ye0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752393Ab3AXAeg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 19:34:36 -0500
Received: by mail-ye0-f169.google.com with SMTP id l13so1413158yen.14
        for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 16:34:36 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1358987262.12374.1283.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 23, 2013 at 04:27:42PM -0800, Eric Dumazet wrote:
> On Wed, 2013-01-23 at 20:20 -0400, Jamie Gloudon wrote:
> 
> > Right. Also, I added rx_dropped to increment for oversize ethernet. Is
> > that valid?
> > 
> > @@ -1857,6 +1869,7 @@ static int rhine_rx(struct net_device *dev, int
> > limit)
> > 	"Oversized Ethernet frame %p vs %p\n", rp->rx_head_desc,                        	&rp->rx_ring[entry]);
> > +	dev->stats.rx_dropped++;
> > 	dev->stats.rx_length_errors++;
> 
> Take other drivers as reference
> 
> git grep -n2 rx_length_errors -- drivers/net
> 
> Most of them dont do that (they are more likely increasing rx_errors)
> 
>

Alright then, I will remove that line and queue up another patch for submission.
Thanks for the feedback!
