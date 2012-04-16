From: David Miller <davem@davemloft.net>
Subject: Re: SV: Netlink, route monitoring, RTM_DELROUTE not issued for ppp
 peer address. Bug or feature?
Date: Mon, 16 Apr 2012 14:40:05 -0400 (EDT)
Message-ID: <20120416.144005.2201460378756236307.davem@davemloft.net>
References: <8986ed37b55c756ecdeec0315f73e63a@visp.net.lb>
	<023e01cd197d$a9faba40$fdf02ec0$@no>
	<3db49d4a58321a5e185cd67335a60c81@visp.net.lb>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stian@nixia.no, eric.dumazet@gmail.com,
	stephen.hemminger@vyatta.com, netdev@vger.kernel.org
To: denys@visp.net.lb
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46685 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751469Ab2DPSkN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2012 14:40:13 -0400
In-Reply-To: <3db49d4a58321a5e185cd67335a60c81@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denys Fedoryshchenko <denys@visp.net.lb>
Date: Mon, 16 Apr 2012 13:37:14 +0300

> So the only solution is to fetch first, then keep full routing table
> in userspace also, and keep tracking if local addresses deleted, and
> do the same in userspace and check for prefsrc...

You don't need to keep full routing table in userspace, don't be
silly.

You only need to watch for the device down event, and purge in
userspace based upon that key.
