From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH RFC 0/5] netfilter: implement netfilter SYN proxy
Date: Wed, 7 Aug 2013 22:59:59 +0200
Message-ID: <20130807205959.GC21463@macbook.localnet>
References: <1375897371-18430-1-git-send-email-kaber@trash.net>
 <1375898766.4004.37.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, mph@one.com, jesper.brouer@gmail.com,
	as@one.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48555 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932387Ab3HGVAE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 17:00:04 -0400
Content-Disposition: inline
In-Reply-To: <1375898766.4004.37.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 07, 2013 at 11:06:06AM -0700, Eric Dumazet wrote:
> On Wed, 2013-08-07 at 19:42 +0200, Patrick McHardy wrote:
> 
> > 
> > The SYNPROXY operates by marking the initial SYN from the client as UNTRACKED
> > and directing it to the SYNPROXY target. The target responds with a SYN/ACK
> > containing a cookie and encodes options such as window scaling factor, SACK
> > perm etc. into the timestamp, if timestamps are used (similar to TCP). The
> > window size is set to zero. The response is also sent as untracked packet.
> 
> TCP timestamps are not really used, for various reasons ...
> 
> Have you taken a look at 
> 
> <http://lists.freebsd.org/pipermail/freebsd-net/2013-July/035999.html>

No, not yet, will have a look. Not sure what you mean by "TCP timestamps
are not really used" though. I might be biased by usually only looking at
Linux traffic, but I was under that impression that everyone is using
TCP timestamps nowadays?
