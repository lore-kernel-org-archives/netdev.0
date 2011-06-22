From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: net/ipv4: commit d0733d2e29b breaks rtorrent
Date: Wed, 22 Jun 2011 08:53:29 -0700
Message-ID: <20110622085329.65c625de@nehalam.ftrdhcpuser.net>
References: <20110622124045.GA3247@localhost>
	<20110622124727.GC19184@suse.de>
	<alpine.LNX.2.00.1106221508310.10066@nitsch.suse.de>
	<20110622145144.GA31734@localhost>
	<alpine.LNX.2.00.1106221654500.20275@nitsch.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Fabienne Ducroquet <fabiduc@gmail.com>,
	Marcus Meissner <meissner@suse.de>, sundell.software@gmail.com,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Reinhard Max <max@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39396 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932210Ab1FVPxc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2011 11:53:32 -0400
In-Reply-To: <alpine.LNX.2.00.1106221654500.20275@nitsch.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 22 Jun 2011 16:58:24 +0200 (CEST)
Reinhard Max <max@suse.de> wrote:

> 
> On Wed, 22 Jun 2011 at 16:51, Fabienne Ducroquet wrote:
> 
> > If I understand correctly, it is trying to bind an IPv6 address to a 
> > socket expecting an IPv4 address, so it's a bug in 
> > libtorrent/rtorrent, but it was not visible before because an 
> > INADDR_ANY bind is not a problem for rtorrent?
> 
> Yes, exactly.
> 
> 
> cu
>  	Reinhard

You can find code here http://libtorrent.rakshasa.no/
but it is in C++ so there is an abnormally high indirection factor
between reality of the bug and the code as written.

Did you try contacting the developer?
