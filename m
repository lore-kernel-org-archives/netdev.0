From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCHv3] ipv6: Enable enough of the code to handle GSO when
 disabled.
Date: Wed, 17 Oct 2012 17:50:36 +0100
Message-ID: <1350492636.2884.5.camel@bwh-desktop.uk.solarflarecom.com>
References: <1350488802-24071-1-git-send-email-vyasevic@redhat.com>
	 <1350490397.26103.647.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vyasevic@redhat.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:26386 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756468Ab2JQQuk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2012 12:50:40 -0400
In-Reply-To: <1350490397.26103.647.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-10-17 at 18:13 +0200, Eric Dumazet wrote:
> On Wed, 2012-10-17 at 11:46 -0400, Vlad Yasevich wrote:
> 
> > This patch attempts to solve this by enabling just enough code so GSO
> > is correctly processed.  However, I should point out that if IPv6 is
> > simply blacklisted or not built for the kernel, this problem will
> > still persist.
> 
> So I guess this should be done in a different way ?
> 
> We currently use a single structure (struct packet_type) to hold 
> pointers to different methods. (The .func() field, and the gso/gro
> stuff)
> 
> We probably need to split it in two parts, and make one part linked into
> kernel, even if CONFIG_IPV6=n, so that GRO/GSO is fully IPv4/IPv6
> functional.
[...]

Either that or make sure that we don't advertise IPv6 GSO when IPv6 is
disabled.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
