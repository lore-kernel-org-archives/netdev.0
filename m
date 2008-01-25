From: Frans Pop <elendil@planet.nl>
Subject: Re: [PATCH] [NET]: Remove PowerPC code from fec.c
Date: Fri, 25 Jan 2008 17:31:54 +0100
Message-ID: <200801251731.56378.elendil@planet.nl>
References: <4799F349.9090102@scram.de> <E1JIQpQ-0006Xj-RR@faramir.fjphome.nl> <479A087F.5010305@scram.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: galak@kernel.crashing.org, geert@linux-m68k.org, gerg@uclinux.org,
	jgarzik@pobox.com, linux-kernel@vger.kernel.org,
	linux-m68k@vger.kernel.org, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, scottwood@freescale.com,
	vitb@kernel.crashing.org
To: Jochen Friedrich <jochen@scram.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hpsmtp-eml11.kpnxchange.com ([213.75.38.111]:3984 "EHLO
	hpsmtp-eml11.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752785AbYAYQcB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2008 11:32:01 -0500
In-Reply-To: <479A087F.5010305@scram.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 25 January 2008, Jochen Friedrich wrote:
> > Jochen Friedrich wrote:
> >> +++ b/drivers/net/fec.c
> >> @@ -23,6 +23,9 @@
> >>   *
> >>   * Bug fixes and cleanup by Philippe De Muyter (phdm@macqel.be)
> >>   * Copyright (c) 2004-2006 Macq Electronique SA.
> >> + *
> >> + * This driver is now only used on ColdFire processors. Remove conditional
> >> + * Powerpc code. 
> >>   */
> >
> > This comment makes sense for a changelog, but IMO it makes no sense at
> > all to add it to the file.
>
> I just added it to clarify this code is now only used on m68knommu
> (Coldfire). The comments on top are mailny about MPC860T CPUs (PowerPC),
> however the driver is no longer used for these CPUs.
>
> Maybe the wording should be changed to:
>
> This driver is now only used on ColdFire (m68knommu) processors.
> Conditional PowerPC code has been removed.

Yes, that certainly makes more sense, although IMHO the second sentence is
still somewhat redundant. (My problem was mainly with the second sentence.
I should have made that more clear, sorry.)
