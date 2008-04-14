From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 2/5] e1000e: Add interrupt moderation run-time ethtool interface
Date: Mon, 14 Apr 2008 21:24:06 +0200
Message-ID: <873apoutnt.fsf@basil.nowhere.org>
References: <20080414170557.23286.71580.stgit@localhost.localdomain>
	<20080414170604.23286.86187.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out03.alice-dsl.net ([88.44.63.5]:39189 "EHLO
	smtp-out03.alice-dsl.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756539AbYDNTYr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 15:24:47 -0400
In-Reply-To: <20080414170604.23286.86187.stgit@localhost.localdomain> (Auke Kok's message of "Mon, 14 Apr 2008 10:06:04 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Auke Kok <auke-jan.h.kok@intel.com> writes:

> The ethtool -c / -C interface can now be used to modify the
> irq moderation algorithm. This change does not require an
> adapter reset and can thus be used at all times. The adapter
> only supports changing/reading rx-usecs which has special
> values for 0, 1 and 3:
>
> 0 - no irq moderation whatsoever
> 1 - normal moderation favoring regular mixed traffic (default)
> 3 - best attempt at low latency possible at cost of CPU

It would be nice if ethtool instead of having this as a obscure magic
number had a higher level "--low-latency" or similar parameter
(that could also potentially set similar settings on other NICs)

You think there would be a clean way to implement this? 

-Andi
