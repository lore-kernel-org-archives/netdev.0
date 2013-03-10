From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH] Rate should be u64 to avoid integer overflow at high
 speeds (>= ~35Gbit)
Date: Sun, 10 Mar 2013 00:49:04 -0500
Message-ID: <20130310004904.de508bfa.billfink@mindspring.com>
References: <1362885604-14006-1-git-send-email-j.vimal@gmail.com>
	<1362888229.4051.2.camel@edumazet-glaptop>
	<CAK3Ji11Mij3Y_sGC6nLS01rxfccZo0SPJmQy-LAmskz1OEdmkQ@mail.gmail.com>
	<1362891937.4051.25.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Vimal <j.vimal@gmail.com>, netdev@vger.kernel.org,
	shemminger <shemminger@vyatta.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-junco.atl.sa.earthlink.net ([209.86.89.63]:59782 "EHLO
	elasmtp-junco.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751206Ab3CJFzR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Mar 2013 00:55:17 -0500
In-Reply-To: <1362891937.4051.25.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 10 Mar 2013, Eric Dumazet wrote:

> On Sat, 2013-03-09 at 20:53 -0800, Vimal wrote:
> > Ok, do you have suggestions on how to do this?  Maybe a better way to
> > do this would be to introduce an additional "multipler" option for
> > rates, which is set to 1 as default, so actual rate can be computed as
> > multipler * rate supplied.
> 
> How an old program, in binary form, will automatically knows it has to
> change its behavior to use an inexistent field ?
> 
> I can use an old distro, and update kernel to upstream kernel, it must
> continue to work.

I don't see the problem.  An old program would not know about
the new multiplier, would thus get the default multiplier of 1,
and get the same behavior as always, with the same limitation
of ~34 Gbps.  But someone with a newer tc/kernel could for example
specify a multiplier of 10, which would then support rates up to
about 340 Gbps.  It sounds like a reasonable approach to me.

						-Bill
