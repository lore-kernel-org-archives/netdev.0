From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch net-next] ipv6: allow userspace to create address with IFLA_F_TEMPORARY flag
Date: Tue, 29 Oct 2013 01:13:40 +0100
Message-ID: <20131029001340.GC26185@order.stressinduktion.org>
References: <20131027164835.GB4714@order.stressinduktion.org> <20131028.171725.1076499130782328273.davem@davemloft.net> <1383002179.28991.14.camel@dcbw.foobar.com> <20131028.200810.66180312939474324.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: dcbw@redhat.com, jiri@resnulli.us, vyasevich@gmail.com,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, thaller@redhat.com,
	stephen@networkplumber.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:34915 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753546Ab3J2ANl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Oct 2013 20:13:41 -0400
Content-Disposition: inline
In-Reply-To: <20131028.200810.66180312939474324.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 28, 2013 at 08:08:10PM -0400, David Miller wrote:
> From: Dan Williams <dcbw@redhat.com>
> Date: Mon, 28 Oct 2013 18:16:19 -0500
> 
> > On Mon, 2013-10-28 at 17:17 -0400, David Miller wrote:
> > First off, what's the reasoning behind having IPv6 privacy as a config
> > option?  It's off-by-default and must be explicitly turned on, so is
> > there any harm in removing the config?  Or is it just for
> > smallest-kernel-ever folks?
> 
> I think it's for "smallest kernel ever" stuff.  Even every arch
> defconfig that mentions it has it enabled :-)
> 
> Maybe it was optional initially because the code was new and
> experimental'ish.  I don't know.
> 
> Regardless of the reason I think it only obfuscates the code with
> ifdefs right now and I would be happy to see it disappear.
> 
> Any objections to this patch?

Yeah, I changed my mind. The ifdefs are really hideous. Fine for me.

Greetings,

  Hannes
