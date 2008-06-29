From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 0/3] Add support for rx flow hash configuration in a network device
Date: Sun, 29 Jun 2008 14:17:56 +0200
Message-ID: <871w2gph8r.fsf@basil.nowhere.org>
References: <48658078.8030707@Sun.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, jeff@garzik.org,
	Matheos.Worku@Sun.COM, Michael.Speer@Sun.COM,
	gkernel-commit@lists.sourceforge.net
To: Santwona Behera <Santwona.Behera@Sun.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out03.alice-dsl.net ([88.44.63.5]:27171 "EHLO
	smtp-out03.alice-dsl.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752314AbYF2MSw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jun 2008 08:18:52 -0400
In-Reply-To: <48658078.8030707@Sun.COM> (Santwona Behera's message of "Fri, 27 Jun 2008 17:06:16 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Santwona Behera <Santwona.Behera@Sun.COM> writes:

> Added new interface to ethtool to configure receive network flow
> classification. This patch adds support for flow distribution using
> hashing where the device can be configured with the fields in the
> receive packet to hash onto one of the multiple Rx rings.
>
> This feature has 3 related patches:
>
> 1. An ethtool application patch.
> 2. A kernel patch for the ethtool interface.
> 3. A kernel patch for the niu driver that implements the ethtool
> config ioctl functions. NOTE: The niu driver already has rx flow
> hashing implemented. With these 3 patches, this feature is now
> configurable using ethtool.

Are you sure ethtool is the right interface for this?

Me thinks the kernel should just do the right thing automatically
for this, by distributing the flows over CPUs.

-Andi
