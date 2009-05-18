From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: HTB accuracy for high speed
Date: Mon, 18 May 2009 15:02:34 -0700
Message-ID: <20090518150234.0f57b263@nehalam>
References: <298f5c050905150745p13dc226eia1ff50ffa8c4b300@mail.gmail.com>
	<298f5c050905150749s3597328dr8dd15adbd7a37532@mail.gmail.com>
	<20090515111227.7fc758cd@nehalam>
	<298f5c050905180301s1c4ffdb2p61a155668eb39bd2@mail.gmail.com>
	<20090518091314.06bf60d2@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Antonio Almeida <vexwek@gmail.com>, netdev@vger.kernel.org,
	jarkao2@gmail.com, kaber@trash.net, davem@davemloft.net,
	devik@cdi.cz
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49187 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751722AbZERWCj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 May 2009 18:02:39 -0400
In-Reply-To: <20090518091314.06bf60d2@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 18 May 2009 09:13:14 -0700
Stephen Hemminger <shemminger@vyatta.com> wrote:

> On Mon, 18 May 2009 11:01:21 +0100
> Antonio Almeida <vexwek@gmail.com> wrote:
> 
> > Hi!
> > 
> > cat /sys/devices/system/clocksource/clocksource0/current_clocksource
> > returns "jiffies"
> 
> That is the slowest of the choices. Better ones are hpet and tsc, but you
> hardware doesn't support them.
> 
> You should compile your kernel with HZ=1000 and the resolution will be better
> (but with some loss of performance).
> --

Are you using one of the AMD dual core machines?  That processor has the bad
design flaw that the TSC counter is not synced between core's so the kernel can't
use it. You might even be better off running a non SMP kernel on that box.
