From: Chris Adams <cmadams@hiwaay.net>
Subject: Re: Use of 802.3ad bonding for increasing link throughput
Date: Wed, 10 Aug 2011 08:23:28 -0500
Message-ID: <20110810132328.GA14311@hiwaay.net>
References: <4E427499.8060108@cyconix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fly.hiwaay.net ([216.180.54.1]:37962 "EHLO fly.hiwaay.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750857Ab1HJNX3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Aug 2011 09:23:29 -0400
Received: from fly.hiwaay.net (localhost.localdomain [127.0.0.1])
	by fly.hiwaay.net (8.13.8/8.13.8/fly) with ESMTP id p7ADNSpq014064
	for <netdev@vger.kernel.org>; Wed, 10 Aug 2011 08:23:28 -0500
Received: (from cmadams@localhost)
	by fly.hiwaay.net (8.13.8/8.13.8/fly-submit) id p7ADNSPe014045
	for netdev@vger.kernel.org; Wed, 10 Aug 2011 08:23:28 -0500
Content-Disposition: inline
In-Reply-To: <4E427499.8060108@cyconix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Once upon a time, Tom Brown <sa212+glibc@cyconix.com> said:
> So, under what circumstances would a user actually use 802.3ad mode to 
> "increase" link throughput, rather than just for redundancy? Are there 
> any circumstances in which a single file, for example, could be 
> transferred at multiple-NIC speed? The 3 hashing options are:

It isn't going to increase the rate for a single stream.  However, few
setups have only a single TCP stream going across a segment, so this is
still quite useful for real-world setups to increase the total
throughput.

-- 
Chris Adams <cmadams@hiwaay.net>
Systems and Network Administrator - HiWAAY Internet Services
I don't speak for anybody but myself - that's enough trouble.
