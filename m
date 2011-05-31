From: Chris Adams <cmadams@hiwaay.net>
Subject: IPv6 support for route realm/flow attribute?
Date: Tue, 31 May 2011 15:33:11 -0500
Message-ID: <20110531203311.GD16380@hiwaay.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fly.hiwaay.net ([216.180.54.1]:41676 "EHLO fly.hiwaay.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758301Ab1EaUjX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 May 2011 16:39:23 -0400
Received: from fly.hiwaay.net (localhost [127.0.0.1])
	by fly.hiwaay.net (8.13.8/8.13.8/fly) with ESMTP id p4VKXBoq014429
	for <netdev@vger.kernel.org>; Tue, 31 May 2011 15:33:11 -0500
Received: (from cmadams@localhost)
	by fly.hiwaay.net (8.13.8/8.13.8/fly-submit) id p4VKXBfZ014425
	for netdev@vger.kernel.org; Tue, 31 May 2011 15:33:11 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It looks like the IPv6 routing table doesn't support the realm/flow
attribute (RTA_FLOW).  Is this something that somebody is planning to
add?

I ask because this is very useful for traffic control setups.  I'm
importing routes via BGP and setting the realm based on the AS path, so
I can rate-limit outbound traffic based on the destination AS.

-- 
Chris Adams <cmadams@hiwaay.net>
Systems and Network Administrator - HiWAAY Internet Services
I don't speak for anybody but myself - that's enough trouble.
