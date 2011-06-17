From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 0/2] Allow NICs to pass Frame Checksum up the stack.
Date: Fri, 17 Jun 2011 21:57:02 +0100
Message-ID: <1308344222.2831.20.camel@bwh-desktop>
References: <1308339615-5866-1-git-send-email-greearb@candelatech.com>
	 <BANLkTikiNT1F39XaMFWc67OuP=StmntL=g@mail.gmail.com>
	 <4DFBBD83.9040300@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>,
	netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:2453 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756809Ab1FQU5F convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 16:57:05 -0400
In-Reply-To: <4DFBBD83.9040300@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-06-17 at 13:48 -0700, Ben Greear wrote:
> On 06/17/2011 01:00 PM, Micha=C5=82 Miros=C5=82aw wrote:
> > 2011/6/17<greearb@candelatech.com>:
> >> From: Ben Greear<greearb@candelatech.com>
> >>
> >> This series provides ethtool support to set and get the rx-checksu=
m
> >> flag, and adds support to the e100 driver.
> > [...]
> >
> > If you want to test the new features approach, you can shave top bi=
t
> > off NETIF_F_GSO_MASK (there are two unused bits there). The
> > introducing patch will be +2 lines (+1 dev.c, +1 ethtool.c),
> > implementation in e100: 20 lines less than patch you sent, ethtool
> > userspace changes: none (assuming
> > http://patchwork.ozlabs.org/patch/96374/ or equivalent applied).
>=20
> Well, is that patch going in?
>=20
> How do we get more bits if we need more than two?  Totally new
> API?

See this thread:
http://thread.gmane.org/gmane.linux.network/196684

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

