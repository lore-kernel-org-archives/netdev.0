From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 2/2] net: doc: add default value for neighbour
 parameters
Date: Thu, 6 Dec 2012 20:20:23 +0000
Message-ID: <1354825223.2828.17.camel@bwh-desktop.uk.solarflarecom.com>
References: <50BED29B.4050805@gmail.com>
	 <1354758235.17107.131.camel@deadeye.wl.decadent.org.uk>
	 <50C009E9.6050101@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	NetDev <netdev@vger.kernel.org>
To: Shan Wei <shanwei88@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:6512 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1947046Ab2LFUU0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2012 15:20:26 -0500
In-Reply-To: <50C009E9.6050101@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-12-06 at 10:58 +0800, Shan Wei wrote:
> Ben Hutchings said, at 2012/12/6 9:43:
> >>  neigh/default/unres_qlen - INTEGER
> >>  	The maximum number of packets which may be queued for each
> >>  	unresolved address by other network layers.
> >>  	(deprecated in linux 3.3) : use unres_qlen_bytes instead.
> >> +	Prior to linux 3.3, the default value is 3 which may cause
> >> +	secluded packet loss. The current default value is calculated
> >           ^^^^^^^^
> > I think the proper word here is 'silent'?
>  
> The number of lost packets is recorded in unresolved_discards
> of /proc/net/stat/arp_cache. Although, arp_cache is not easy
> to understand(I still don't know why we need so many rows),
> We can confirm dropping event from unresolved_discards in last column.
> The dropping event is not marked by absence of sound.
> 
> But for general user who using TCP/UDP or ping to sending packets
> out, can't simply find the dropping reason that destination ip is unresolved.
> They just doubt about the TCP/UDP or ping. So I use 'secluded' which is hidden
> from general view.
> 
> My English is not good enough, if missing something, please point to me.
> Thanks.

'Secluded' is a fine word but your dictionary should have said that it
is used to describe places, not events.  You're quite right that this is
not silent, though.  So a word like 'hidden', 'quiet', 'non-obvious' or
'unexpected' would be more appropriate.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
