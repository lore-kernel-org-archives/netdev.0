From: Reinhard Max <max@suse.de>
Subject: Re: net/ipv4: commit d0733d2e29b breaks rtorrent
Date: Wed, 22 Jun 2011 16:58:24 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1106221654500.20275@nitsch.suse.de>
References: <20110622124045.GA3247@localhost> <20110622124727.GC19184@suse.de> <alpine.LNX.2.00.1106221508310.10066@nitsch.suse.de> <20110622145144.GA31734@localhost>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Marcus Meissner <meissner@suse.de>, sundell.software@gmail.com,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Fabienne Ducroquet <fabiduc@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:46604 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757939Ab1FVO60 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2011 10:58:26 -0400
In-Reply-To: <20110622145144.GA31734@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 22 Jun 2011 at 16:51, Fabienne Ducroquet wrote:

> If I understand correctly, it is trying to bind an IPv6 address to a 
> socket expecting an IPv4 address, so it's a bug in 
> libtorrent/rtorrent, but it was not visible before because an 
> INADDR_ANY bind is not a problem for rtorrent?

Yes, exactly.


cu
 	Reinhard
