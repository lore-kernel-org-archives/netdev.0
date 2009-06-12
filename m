From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: Re: [RFC PATCH] Ethtool style in kernel network driver
	configuration.
Date: Fri, 12 Jun 2009 11:50:20 +0100
Message-ID: <20090612105019.GA21599@sirena.org.uk>
References: <alpine.LFD.2.00.0906111159080.31536@xanadu.home> <1244739166.2785.52.camel@achroite> <ba4215e10906111045yf7288fbt4495d4dc96217d65@mail.gmail.com> <20090611.170948.66762524.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mfuzzey@gmail.com, bhutchings@solarflare.com, nico@cam.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassiel.sirena.org.uk ([80.68.93.111]:47923 "EHLO
	cassiel.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753519AbZFLKuW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2009 06:50:22 -0400
Content-Disposition: inline
In-Reply-To: <20090611.170948.66762524.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 11, 2009 at 05:09:48PM -0700, David Miller wrote:

> You can instantiate a platform_device that the driver matches
> and uses to acquire board-specific-juju such as link modes
> which are non-functional.

How would you handle PCI devices in that scheme?  Last time I looked at
this (a while ago, so I may be out of date) there didn't appear to be a
sensible generic way of getting platform data to PCI devices.
