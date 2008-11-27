From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 00/39] merge request for WiMAX kernel stack and i2400m driver v2
Date: Thu, 27 Nov 2008 12:47:53 +0100
Message-ID: <87k5ap2xw6.fsf@basil.nowhere.org>
References: <cover.1227691434.git.inaky@linux.intel.com>
	<1227783281.3809.78.camel@johannes.berg>
	<00E41CD2-3C1B-4B39-8720-698DBC236CE8@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Inaky Perez-Gonzalez <inaky@linux.intel.com>,
	netdev <netdev@vger.kernel.org>
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:36170 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752599AbYK0Lrs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 06:47:48 -0500
In-Reply-To: <00E41CD2-3C1B-4B39-8720-698DBC236CE8@holtmann.org> (Marcel Holtmann's message of "Thu, 27 Nov 2008 12:14:30 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marcel Holtmann <marcel@holtmann.org> writes:
>
> Either we do Ethernet framing or a pure IP device. I am for the pure
> IP device with a separate ARP header (which we managed to get
> allocated). Wrapping everything into Ethernet only because dhclient is
> broken is not an answer. An alternate option would be a point-to-point

It's not only dhclient, but also lots of other raw packet users like
tcpdump etc.

> device like the HSO driver or PPP is using. However then the usage of
> DHCP becomes a lot more trickier.

I personally think user convenience is more important at least short term.
It's also not that the pseudo header is that much overhead.

-Andi
-- 
ak@linux.intel.com
